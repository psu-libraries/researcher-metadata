FactoryBot.define do
  factory :scholarsphere_file_upload do
    file { fixture_file_open('test_file.pdf') }
  end
end
