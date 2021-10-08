# frozen_string_literal: true

FactoryBot.define do
  factory :presentation do
    sequence(:activity_insight_identifier) { |n| "ai_#{n}" }
  end
end
