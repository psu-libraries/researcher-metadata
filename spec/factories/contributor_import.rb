FactoryBot.define do
  factory :contributor_import do
    publication_import { create :publication_import }
    position { 1 }
    source_identifier { 'abc123' }
    import_source { 'Activity Insight' }
  end
end
