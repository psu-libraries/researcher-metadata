# frozen_string_literal: true

FactoryBot.define do
  factory :publication_import do
    publication { build(:publication) }
    source { 'Pure' }
    sequence(:source_identifier) { |n| "pure_id_#{n}" }

    trait :from_activity_insight do
      source { 'Activity Insight' }
      source_identifier { rand(10000000..99999999) }
    end

    trait :from_pure do
      source { 'Pure' }
      source_identifier { FFaker::Lorem.characters(50) }
    end
  end
end
