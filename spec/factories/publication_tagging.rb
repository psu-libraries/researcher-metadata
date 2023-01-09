# frozen_string_literal: true

FactoryBot.define do
  factory :publication_tagging do
    publication { create(:publication) }
    tag { create(:tag) }
  end
end
