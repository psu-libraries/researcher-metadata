# frozen_string_literal: true

FactoryBot.define do
  factory :researcher_fund do
    grant { create(:grant) }
    user { create(:user) }
  end
end
