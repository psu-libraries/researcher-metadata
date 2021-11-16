# frozen_string_literal: true

class NewDeputyAssignmentForm
  class IdentityServiceError < StandardError; end

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
      validate_deputy_assignment_does_not_already_exist(deputy: deputy)
      return false if errors.any?

      create_deputy_assignment(primary: primary, deputy: deputy)
    rescue StandardError
      errors.add(:base, :unknown_error)
    end

    errors.empty?
  end

  private

    def find_or_initialize_deputy(webaccess_id:)
      User.find_by(webaccess_id: webaccess_id) ||
        initialize_user_from_psu_identity(webaccess_id: webaccess_id)
    end

    def initialize_user_from_psu_identity(webaccess_id: webaccess_id)
      psu_identity = query_psu_identity(webaccess_id)
      if psu_identity.blank?
        errors.add(:deputy_webaccess_id, :not_found)
        return nil
      end

      # TODO this should be refactored along with
      # User#attributes_from_psu_identity to share a common service
      new_user = User.new(
        webaccess_id: webaccess_id,
        first_name: (psu_identity.preferred_given_name.presence || psu_identity.given_name),
        last_name: (psu_identity.preferred_family_name.presence || psu_identity.family_name),
        psu_identity: psu_identity,
        psu_identity_updated_at: Time.zone.now
      )

      new_user.validate!

      new_user
    rescue ActiveRecord::RecordInvalid
      errors.add(:base, :error_creating_user)
      nil
    rescue IdentityServiceError
      errors.add(:base, :identity_service_error)
      nil
    end

    def validate_deputy_assignment_does_not_already_exist(deputy:)
      return if deputy.nil? || deputy.new_record?

      existing_deputy_assignment = DeputyAssignment
        .where(primary: primary, deputy: deputy)
        .active
        .any?

      errors.add(:deputy_webaccess_id, :already_assigned) if existing_deputy_assignment
    end

    def create_deputy_assignment(primary:, deputy:)
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

    def query_psu_identity(webaccess_id)
      PsuIdentity::SearchService::Client.new.userid(webaccess_id)
    rescue URI::InvalidURIError
      nil
    rescue StandardError
      raise IdentityServiceError
    end
end
