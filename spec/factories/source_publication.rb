# frozen_string_literal: true

FactoryBot.define do
  factory :source_publication do
    import { create(:import) }
    source_identifier { 'asdf' }
  end
end
