FactoryBot.define do
  factory :user_performance do
    user { create :user }
    performance { create :performance, visible: true }
  end
end
