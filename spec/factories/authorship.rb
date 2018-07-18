FactoryBot.define do
  factory :authorship do
    publication { create :publication }
    user { create :user }
    author_number { 1 }
  end
end
