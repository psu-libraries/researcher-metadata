# frozen_string_literal: true

FactoryBot.define do
  factory :email_error do
    user { create(:user) }
  end
end
