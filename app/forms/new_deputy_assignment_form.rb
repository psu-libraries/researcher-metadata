# frozen_string_literal: true

class NewDeputyAssignmentForm
  class IdentityServiceError < StandardError; end
  class IdentityNotFound < StandardError; end
  class AlreadyAssigned < StandardError; end
  class ErrorCreatingUser < StandardError; end

  include ActiveModel::Model

  attr_accessor :primary,
                :deputy_webaccess_id

  validates :primary,
            presence: true

  validates :deputy_webaccess_id,
            presence: true,
            format: {
              with: /\A[a-z0-9]+\z/i,
              allow_blank: true
            }

  def save
    return false unless valid?

    begin
      deputy = find_or_initialize_deputy(webaccess_id: deputy_webaccess_id)
      create_deputy_assignment(primary: primary, deputy: deputy)
    rescue IdentityServiceError
      errors.add(:base, :identity_service_error)
    rescue IdentityNotFound
      errors.add(:deputy_webaccess_id, :not_found)
    rescue AlreadyAssigned
      errors.add(:deputy_webaccess_id, :already_assigned)
    rescue ErrorCreatingUser
      errors.add(:base, :error_creating_user)
    rescue StandardError
      errors.add(:base, :unknown_error)
    end

    errors.empty?
  end

  private

    def find_or_initialize_deputy(webaccess_id:)
      User.find_or_initialize_by(webaccess_id: webaccess_id) do |new_user|
        psu_identity = query_psu_identity(webaccess_id)
        raise IdentityNotFound if psu_identity.blank?

        new_user.first_name = psu_identity.given_name
        new_user.last_name = psu_identity.family_name
        new_user.psu_identity = psu_identity

        raise ErrorCreatingUser unless new_user.valid?
      end
    end

    def create_deputy_assignment(primary:, deputy:)
      if deputy.persisted?
        existing_deputy_assignment = DeputyAssignment.active.find_by(
          primary: primary,
          deputy: deputy
        )
        raise AlreadyAssigned if existing_deputy_assignment.present?
      end

      begin
        DeputyAssignment.create!(
          primary: primary,
          deputy: deputy,
          is_active: true
        )
      rescue ActiveRecord::RecordInvalid => e
        e.record.errors.each do |err|
          if err.match?(:deputy)
            errors.add(:deputy_webaccess_id, err.message)
          else
            errors.add(:base, err.full_message)
          end
        end
      end
    end

    def query_psu_identity(webaccess_id)
      PsuIdentity::SearchService::Client.new.userid(webaccess_id)
    rescue URI::InvalidURIError
      raise IdentityNotFound
    rescue StandardError
      raise IdentityServiceError
    end
end
