FactoryBot.define do
  factory :user do
    webaccess_id { 'abc123' }
    person { create :person }
  end
end
