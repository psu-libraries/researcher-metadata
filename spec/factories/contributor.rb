# frozen_string_literal: true

FactoryBot.define do
  factory :contributor_name do
    publication { create(:publication) }
    position { 1 }
    first_name { 'first' }

    factory :sample_contributor_name do
      first_name { FFaker::Name.first_name }
      last_name { FFaker::Name.last_name }
    end
  end
end
