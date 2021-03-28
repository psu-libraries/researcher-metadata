FactoryBot.define do
  factory :scholarsphere_work_deposit do
    authorship { create :authorship }
    status { 'Pending' }
  end
end
