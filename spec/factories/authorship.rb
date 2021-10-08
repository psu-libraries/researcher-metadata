# frozen_string_literal: true

FactoryBot.define do
  factory :authorship do
    publication { create :publication, visible: true }
    user { create :user }
    author_number { 1 }
  end
end
