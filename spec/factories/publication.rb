# frozen_string_literal: true

FactoryBot.define do
  factory :publication do
    title { 'Test' }
    publication_type { 'Academic Journal Article' }
    open_access_status { 'closed' }
  end
end
