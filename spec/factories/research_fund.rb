# frozen_string_literal: true

FactoryBot.define do
  factory :research_fund do
    grant { create(:grant) }
    publication { create(:publication) }
  end
end
