# frozen_string_literal: true

FactoryBot.define do
  factory :tag do
    sequence :name do |n|
      "abc#{n}"
    end
  end
end
