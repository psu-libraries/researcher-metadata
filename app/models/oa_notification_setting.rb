class OaNotificationSetting < ApplicationRecord
  # There should only be one OaNotificationSetting record
  validate :one_record_validation

  def self.email_cap
    first.email_cap
  end

  def self.is_active
    first.is_active
  end

  def self.is_not_active
    !first.is_active
  end

  def self.seed
    return if count > 0

    create email_cap: 300, is_active: true
  end

  private

    def one_record_validation
      errors.add(:a_record_exists, ', there can only be one OaNotificationSetting record') if self.class.count > 0
    end
end
