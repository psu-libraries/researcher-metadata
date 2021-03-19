FactoryBot.define do
  factory :scholarsphere_file_upload do
    work_deposit { create :scholarsphere_work_deposit }
    file { fixture_file_open('test_file.pdf') }
  end
end
