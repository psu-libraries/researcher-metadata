# frozen_string_literal: true

FactoryBot.define do
  factory :open_access_location do
    publication
    source { Source::USER }
    url { 'test_url' }
  end
end
