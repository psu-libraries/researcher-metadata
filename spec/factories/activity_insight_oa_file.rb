# frozen_string_literal: true

FactoryBot.define do
  factory :activity_insight_oa_file do
    publication
    location { 'abc123/intellcont/test_file.pdf' }
    version { I18n.t('file_versions.accepted_version') }
  end
end
