FactoryBot.define do
  factory :performance_screening do
    performance { create :performance }
    screening_type 'Invited'
    name 'Test Performance'
    location 'City, State'
  end
end
