# frozen_string_literal: true

FactoryBot.define do
  factory :deputy_assignment do
    primary factory: [:user, :with_psu_identity]
    deputy factory: [:user, :with_psu_identity]
    is_active { true }
    confirmed_at { Time.zone.now }

    trait :active do
      is_active { true }
    end

    trait :inactive do
      is_active { false }
      sequence(:active_uniqueness_key)
    end

    trait :confirmed do
      confirmed_at { Time.zone.now }
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end
  end
end
