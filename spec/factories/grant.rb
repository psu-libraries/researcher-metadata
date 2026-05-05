# frozen_string_literal: true

FactoryBot.define do
  factory :grant do
    sequence(:identifier) { |n| "grant_#{n}" }
    agency_name { 'NSF' }
  end
end
