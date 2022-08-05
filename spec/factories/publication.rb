# frozen_string_literal: true

FactoryBot.define do
  factory :publication do
    transient do
      user { create :sample_user }
    end

    title { 'Test' }
    publication_type { 'Academic Journal Article' }
    status { 'Published' }
    open_access_status { 'closed' }

    factory :sample_publication do
      title { FFaker::Lorem.sentence }
      secondary_title { FFaker::Lorem.sentence }
      journal { Journal.count.zero? ? FactoryBot.create(:journal) : Journal.order('RANDOM()').first }
      abstract { FFaker::Lorem.paragraph }
      isbn { FFaker::Book.isbn }
      volume { rand(50) }
      edition { rand(50) }
      doi { "https://doi.org/10.#{rand(1000..9999)}/#{FFaker::Internet.ip_v4_address}" }
      published_on { Date.today - 6.months }

      after :create do |pub, options|
        create :sample_contributor_name, publication: pub
        create :authorship, publication: pub, user: options.user
      end
    end

    trait :journal_article do
      publication_type {
        Publication.publication_types.grep(/Journal Article/).sample
      }
    end

    trait :other_work do
      publication_type {
        Publication.publication_types.select { |type| type.exclude?('Journal Article') }.sample
      }
    end

    trait :with_open_access_location do
      after :create do |pub|
        create :sample_open_access_location, publication: pub
      end
    end

    trait :in_press do
      status { 'In Press' }
    end

    trait :from_activity_insight do
      after :create do |pub|
        create :publication_import, :from_activity_insight, publication: pub
      end
    end

    trait :from_pure do
      after :create do |pub|
        create :publication_import, :from_pure, publication: pub
      end
    end

    trait :with_duplicate_group do
      duplicate_publication_group_id { (create :duplicate_publication_group).id }

      after :create do |pub|
        create :sample_publication,
               :journal_article,
               :from_activity_insight,
               title: pub.title,
               doi: pub.doi,
               duplicate_publication_group_id: pub.duplicate_publication_group_id
      end
    end

    trait :with_non_duplicate_group do
      duplicate_publication_group_id { (create :duplicate_publication_group).id }

      after :create do |pub|
        pub2 = create :sample_publication,
                      :journal_article,
                      :from_activity_insight,
                      title: pub.title,
                      doi: pub.doi,
                      duplicate_publication_group_id: pub.duplicate_publication_group_id

        create :non_duplicate_publication_group_membership,
               publication: pub,
               non_duplicate_publication_group_id: (create :non_duplicate_publication_group).id

        create :non_duplicate_publication_group_membership,
               publication: pub2,
               non_duplicate_publication_group_id: pub.non_duplicate_groups.first.id
      end
    end
  end
end
