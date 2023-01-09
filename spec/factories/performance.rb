# frozen_string_literal: true

FactoryBot.define do
  factory :performance do
    transient do
      user { create(:sample_user) }
    end

    title { 'Test' }
    sequence(:activity_insight_id) { |n| n }
    performance_type { 'Other' }
    sponsor { 'Test Sponsor' }
    description { 'This is a performance' }
    group_name { 'Test Name' }
    location { 'Test Location' }
    delivery_type { 'Competition' }
    scope { 'Local' }
    start_on { '10-24-18' }
    end_on { '10-27-18' }

    factory :sample_performance do
      title { FFaker::Book.title }
      activity_insight_id { rand(10000000..999999999) }
      performance_type { FFaker::Lorem.word }
      sponsor { FFaker::Education.school }
      description { FFaker::Lorem.paragraph }
      group_name { FFaker::Music.artist }
      location { "#{FFaker::AddressUS.city}, #{FFaker::AddressUS.state}, United States" }
      start_on { Date.today - 6.months }
      end_on { Date.tomorrow - 6.months }
      delivery_type { ['Invitation', 'Competition', 'Audition'].sample }
      scope { ['National', 'International', 'Regional', 'Local'].sample }

      after :create do |perf, options|
        create(:user_performance,
               activity_insight_id: perf.activity_insight_id,
               performance: perf,
               user: options.user)
      end
    end
  end
end
