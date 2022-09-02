# frozen_string_literal: true

class OaNotificationSetting < ApplicationRecord
  # The "singleton_guard" column is a unique column which must always be set to '0'
  # This ensures that only one OaNotificationSettings row is created
  validates :singleton_guard, inclusion: { in: [0] }

  class << self
    def email_cap
      instance.email_cap
    end

    def not_active?
      !instance.is_active
    end

    def instance
      first_or_create!(singleton_guard: 0, email_cap: 100, is_active: true)
    end
  end

  rails_admin do
    edit do
      field(:email_cap)
      field(:is_active)
    end

    show do
      field(:email_cap)
      field(:is_active)
    end

    list do
      field(:email_cap)
      field(:is_active)
    end
  end
end
