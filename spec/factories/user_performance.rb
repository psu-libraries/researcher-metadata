FactoryBot.define do
  factory :user_performance do
    user { create :user }
    performance { create :performance, visible: true }
    sequence(:activity_insight_id) { |n| 1000000000 + n }
  end
end
