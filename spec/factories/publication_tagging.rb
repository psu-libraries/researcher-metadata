FactoryBot.define do
  factory :publication_tagging do
    publication { create :publication }
    tag { create :tag }
  end
end
