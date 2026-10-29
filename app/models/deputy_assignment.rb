# frozen_string_literal: true

# This class wants to ensure that the combination of (primary, deputy) is
# unique, but only among records where `is_active = true`. We want a database
# unique index, because Rail's uniqueness validations are succeptible to race
# conditions. But, how to write a db-level uniqueness constraint that only
# applies to _active_ rows?
#
# One way to do it is to add a third field to the uniqueness index, and manage
# it with activerecord like so:
#   * Set active_uniqueness_key = 0, when is_active = true
#   * Set active_uniqueness_key = the record's id, when deactivating the
#     record
#
# That way, when the record has been deactivated, active_uniqueness_key is a
# guaranteed unique value and excludes that row from the uniquness constraint
#
# There's just one complication, what if someone _creates_ a new model, whose
# is_active flag is set to false. Then we would want to automatically set the
# active_uniqueness_key to the row's ID. Except we can't know the row's id
# until after it's been created, and we need some kind of value in that
# active_uniqueness_key to save it in the first place. In that case, we
# initialize active_uniqueness_key to the current time in millis (pretty much
# guaranteed to work), then update it to the actual row ID after creation when
# we know it.

class DeputyAssignment < ApplicationRecord
  after_initialize :set_defaults
  after_commit :set_active_uniqueness_key_if_inactive

  belongs_to :primary,
             class_name: 'User',
             foreign_key: :primary_user_id,
             inverse_of: :primary_assignments

  belongs_to :deputy,
             class_name: 'User',
             foreign_key: :deputy_user_id,
             inverse_of: :deputy_assignments

  scope :active, -> { where(is_active: true) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }

  validate :primary_and_deputy_cannot_be_the_same,
           :admins_cannot_be_assigned

  validates :deputy,
            uniqueness: {
              scope: [:primary, :active_uniqueness_key],
              if: :is_active?
            }

  def active?
    is_active?
  end

  def confirmed?
    confirmed_at.present?
  end

  def pending?
    !confirmed?
  end

  def confirm!
    return if confirmed?

    update!(confirmed_at: Time.zone.now)
  end

  def deactivate!
    return unless is_active?

    update!(
      is_active: false,
      deactivated_at: Time.zone.now,
      active_uniqueness_key: id
    )
  end

  private

    def set_defaults
      self.is_active = true if is_active.nil?

      # See note at the top of this class for what this does and how.
      self.active_uniqueness_key ||= if is_active?
                                       0
                                     else
                                       # If we are _creating_ an inactive record,
                                       # init with temp value of current time in millis.
                                       # Will update it to the row's id once we know it
                                       (Time.zone.now.to_f * 1000).to_i
                                     end
    end

    # In the rare chance that we need to create an inactive record, we have to
    # initialize the active_uniqueness_key to some psuedounique value because
    # we don't know the row's ID yet. Once it's known (after_commit) then we
    # can update it to the row's actual id.
    #
    # This is an edge case. 99.9% of records will never pass the guards
    def set_active_uniqueness_key_if_inactive
      return if active?
      return if active_uniqueness_key == id

      update_column(:active_uniqueness_key, id)
    end

    def primary_and_deputy_cannot_be_the_same
      errors.add(:deputy, :same_as_primary) if primary == deputy && primary.present?
    end

    def admins_cannot_be_assigned
      errors.add(:primary, :is_admin) if primary&.admin?
      errors.add(:deputy, :is_admin) if deputy&.admin?
    end
end
