# frozen_string_literal: true

FactoryBot.define do
  factory :activity_insight_oa_file do
    publication
    sequence(:location) { |n| "abc123/intellcont/test_file#{n}.pdf" }
    version { nil }
  end
end
