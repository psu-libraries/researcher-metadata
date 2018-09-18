FactoryBot.define do
  factory :contract_import do
    contract { create :contract }
    activity_insight_id { 123456 }
  end
end
