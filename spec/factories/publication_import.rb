FactoryBot.define do
  factory :publication_import do
    publication { create :publication }
    title { 'Test' }
    publication_type { 'Academic Journal Article' }
    source_identifier { 'abc123' }
    import_source { 'Activity Insight' }
  end
end
