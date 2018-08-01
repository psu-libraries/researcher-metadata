FactoryBot.define do
  factory :publication do
    title { 'Test' }
    publication_type { 'Academic Journal Article' }
    sequence(:pure_uuid) { |n| "pure_id_#{n}"}
    sequence(:activity_insight_identifier) { |n| "ai_id_#{n}"}
  end
end
