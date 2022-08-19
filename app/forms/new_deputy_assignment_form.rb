# frozen_string_literal: true

class NewDeputyAssignmentForm
  include ActiveModel::Model

  attr_accessor :primary,
                :deputy_webaccess_id

  attr_reader :deputy_assignment

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

      @deputy_assignment = create_deputy_assignment(primary: primary, deputy: deputy)
    rescue StandardError
      errors.add(:base, :unknown_error)
    end

    errors.empty?
  end

  private

    def find_or_initialize_deputy(webaccess_id:)
      user = PsuIdentityUserService.update_or_initialize_user(webaccess_id: webaccess_id)

      if user.blank?
        errors.add(:deputy_webaccess_id, :not_found)
        return nil
      end

      user.validate! if user.new_record?

      user
    rescue ActiveRecord::RecordInvalid
      errors.add(:base, :error_creating_user)
      nil
    rescue PsuIdentityUserService::IdentityServiceError
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
