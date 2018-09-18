FactoryBot.define do
  factory :user_contract do
    user { create :user }
    contract { create :contract }
  end
end
