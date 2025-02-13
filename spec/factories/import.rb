# frozen_string_literal: true

FactoryBot.define do
  factory :import do
    source { 'Pure' }
    started_at { Time.current }
  end
end
