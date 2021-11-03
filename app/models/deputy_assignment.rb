# frozen_string_literal: true

class DeputyAssignment < ApplicationRecord
  belongs_to :primary,
             class_name: 'User',
             foreign_key: :primary_user_id,
             inverse_of: :primary_assignments

  belongs_to :deputy,
             class_name: 'User',
             foreign_key: :deputy_user_id,
             inverse_of: :deputy_assignments

  validate :primary_and_deputy_cannot_be_the_same,
           :admins_cannot_be_assigned

  validates :deputy, uniqueness: { scope: [:primary] }

  private

    def primary_and_deputy_cannot_be_the_same
      errors.add(:deputy, :same_as_primary) if primary == deputy && primary.present?
    end

    def admins_cannot_be_assigned
      errors.add(:primary, :is_admin) if primary&.admin?
      errors.add(:deputy, :is_admin) if deputy&.admin?
    end
end
