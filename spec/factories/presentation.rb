# frozen_string_literal: true

FactoryBot.define do
  factory :presentation do
    transient do
      user { create :sample_user }
    end

    sequence(:activity_insight_identifier) { |n| "ai_#{n}" }

    factory :sample_presentation do
      title { FFaker::Book.title }
      activity_insight_identifier { rand(10000000..99999999) }
      name { FFaker::Conference.name }
      organization { FFaker::Education.school }
      location { "#{FFaker::AddressUS.city}, #{FFaker::AddressUS.state}, United States" }
      started_on { Date.today - 6.months }
      ended_on { Date.tomorrow - 6.months }
      presentation_type { ['Presentations', 'Lectures', 'Posters', 'Oral Presentations'].sample }
      meet_type { ['Academic', 'Non-Academic'].sample }
      refereed { 'Yes' }
      abstract { FFaker::Lorem.paragraph }
      scope { ['National', 'International', 'Regional', 'Local'].sample }

      after :create do |perf, options|
        create :presentation_contribution,
               presentation: perf,
               user: options.user
      end
    end
  end
end
