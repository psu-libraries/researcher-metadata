FactoryBot.define do
  factory :contributor_name do
    publication { create :publication }
    position { 1 }
    first_name { 'first' }
  end
end
