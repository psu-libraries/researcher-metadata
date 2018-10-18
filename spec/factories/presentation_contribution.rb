FactoryBot.define do
  factory :presentation_contribution do
    presentation { create :presentation, visible: true }
    user { create :user }
  end
end
