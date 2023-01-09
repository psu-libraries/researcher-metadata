# frozen_string_literal: true

FactoryBot.define do
  factory :committee_membership do
    etd { create(:etd) }
    user { create(:user) }
    role { 'Advisor' }
  end
end
