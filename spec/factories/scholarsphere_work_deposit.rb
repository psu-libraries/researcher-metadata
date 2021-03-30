FactoryBot.define do
  factory :scholarsphere_work_deposit do
    authorship { create :authorship }
    status { 'Pending' }
    title { 'Test Title' }
    description { 'Test description.' }
    published_date { Date.new(2020, 1, 1) }
    rights { 'https://creativecommons.org/licenses/by/4.0/' }
    file_uploads { [create(:scholarsphere_file_upload)] }
  end
end
