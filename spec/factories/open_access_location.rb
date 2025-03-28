# frozen_string_literal: true

FactoryBot.define do
  factory :open_access_location do
    publication
    source { Source::USER }
    url { 'test_url' }

    OpenAccessLocation.sources.each do |src_k, src_v|
      trait src_k do
        source { src_v }
      end
    end

    factory :sample_open_access_location do
      source { OpenAccessLocation.sources.keys.sample }
      url { FFaker::Internet.domain_name }
    end
  end
end
