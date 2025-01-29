# frozen_string_literal: true

FactoryBot.define do
  factory :activity_insight_oa_file do
    publication
    user { create(:user, :with_psu_identity) }
    sequence(:location) { |n| "abc123/intellcont/test_file#{n}.pdf" }
    sequence(:intellcont_id) { |n| n + 100000000000 }
    sequence(:post_file_id) { |n| n + 200000000000 }
    version { nil }
    file_download_location { 'path_to_test_file.pdf' }
  end
end
