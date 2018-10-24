FactoryBot.define do
  factory :contract_import do
    contract { create :contract }
    sequence(:activity_insight_id) { |n| n }
  end
end
