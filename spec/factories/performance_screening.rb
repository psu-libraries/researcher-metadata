FactoryBot.define do
  factory :performance_screening do
    performance { create :performance }
    screening_type 'Invited'
    name 'Test Performance'
    location 'City, State'
    sequence( :activity_insight_id ) { |n| 1000000000 + n }
  end
end
