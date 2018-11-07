FactoryBot.define do
  factory :performance do
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
  end
end
