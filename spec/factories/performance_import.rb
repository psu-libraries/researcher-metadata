FactoryBot.define do
  factory :performance_import do
    performance { create :performance }
    sequence(:activity_insight_id) { |n| n }
  end
end
