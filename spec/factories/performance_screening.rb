# frozen_string_literal: true

FactoryBot.define do
  factory :performance_screening do
    performance { create(:performance) }
    screening_type { 'Invited' }
    name { 'Test Performance' }
    location { 'City, State' }
    sequence(:activity_insight_id) { |n| n + 1000000000 }
  end
end
