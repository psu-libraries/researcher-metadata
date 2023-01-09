# frozen_string_literal: true

FactoryBot.define do
  factory :education_history_item do
    user { create(:user) }
  end
end
