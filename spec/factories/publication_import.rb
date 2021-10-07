FactoryBot.define do
  factory :publication_import do
    publication { build :publication }
    source { 'Pure' }
    sequence(:source_identifier) { |n| "pure_id_#{n}" }
  end
end
