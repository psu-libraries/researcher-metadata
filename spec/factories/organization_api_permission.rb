# frozen_string_literal: true

FactoryBot.define do
  factory :organization_api_permission do
    api_token { create :api_token }
    organization { create :organization }
  end
end
