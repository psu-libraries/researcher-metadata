FactoryBot.define do
  factory :user_contract do
    user { create :user }
    contract { create :contract, visible: true }
  end
end
