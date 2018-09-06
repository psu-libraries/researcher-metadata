FactoryBot.define do
  factory :etd do
    sequence :title do |n|
      "abc#{n}"
    end
    sequence :webaccess_id do |n|
      "abc#{n}"
    end
    author_first_name { 'buck' }
    author_last_name { 'murphy' }
    year { 2018 }
    url { 'https://etda.libraries.psu.edu/catalog/7332' }
    submission_type { 'Dissertation' }
    external_identifier { '7332'}
    access_level { 'Open Access' }
  end
end
