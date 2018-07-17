FactoryBot.define do
  factory :contributor do
    publication { create :publication }
    position { 1 }
  end
end
