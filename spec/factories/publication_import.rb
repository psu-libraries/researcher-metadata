FactoryBot.define do
  factory :publication_import do
    publication { create :publication }
    title { 'Test' }
    publication_type { 'Academic Journal Article' }
    sequence(:source_identifier) { |n| n }
    import_source { 'Activity Insight' }
  end
end
