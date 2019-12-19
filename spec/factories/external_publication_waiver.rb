FactoryBot.define do
  factory :external_publication_waiver do
    user { create :user }
    publication_title { "Test Publication" }
    journal_title { "Test Journal" }
  end
end
