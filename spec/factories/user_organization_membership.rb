FactoryBot.define do
  factory :user_organization_membership do
    user { create :user }
    organization { create :organization }
  end
end
