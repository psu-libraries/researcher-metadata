# frozen_string_literal: true

FactoryBot.define do
  factory :activity_insight_oa_file do
    publication
    user
    sequence(:location) { |n| "abc123/intellcont/test_file#{n}.pdf" }
    sequence(:intellcont_id) { |n| 100000000000+n }
    sequence(:post_file_id) { |n| 200000000000+n }
    version { nil }
    file_download_location { 'path_to_test_file.pdf' }
  end
end
