FactoryBot.define do
  factory :user do
    first_name { 'Test' }
    last_name { 'User' }
    webaccess_id { 'abc123' }
  end
end
