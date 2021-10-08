# frozen_string_literal: true

FactoryBot.define do
  factory :internal_publication_waiver do
    authorship { create :authorship }
  end
end
