# frozen_string_literal: true

module DeputyUser
  extend ActiveSupport::Concern

  included do
    # rubocop:disable Rails/InverseOf
    belongs_to :deputy,
               class_name: 'User',
               foreign_key: :deputy_user_id,
               optional: true
    # rubocop:enable Rails/InverseOf

    validate :deputy_must_be_assigned
  end

  private

    # @note We can't tell (easily) if the deputy is associated with the exact user, but we can tell if they have any
    # valid primary users.
    def deputy_must_be_assigned
      return if deputy.nil?

      errors.add(:deputy, :not_assigned) if deputy.deputy_assignments.limit(1).empty?
    end
end
