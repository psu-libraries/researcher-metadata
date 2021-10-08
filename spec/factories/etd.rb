# frozen_string_literal: true

FactoryBot.define do
  factory :etd do
    sequence :title do |n|
      "abc#{n}"
    end
    sequence :webaccess_id do |n|
      "abc#{n}"
    end
    sequence :external_identifier do |n|
      "external_id_#{n}"
    end
    author_first_name { 'buck' }
    author_last_name { 'murphy' }
    year { 2018 }
    url { 'https://etda.libraries.psu.edu/catalog/7332' }
    submission_type { 'Dissertation' }
    access_level { 'Open Access' }
  end
end
