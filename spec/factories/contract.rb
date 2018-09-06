FactoryBot.define do
  factory :contract do
    title { 'Test' }
    contract_type { 'Grant' }
    sponsor { 'Test Sponsor' }
    amount { 1000 }
    sequence(:ospkey) { |n| 123450 + n }
    award_start_on { '9-5-18' }
    award_end_on { '9-5-19' }
  end
end
