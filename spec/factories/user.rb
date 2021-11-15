# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence :webaccess_id do |n|
      "user#{n}"
    end
    first_name { 'Test' }
    last_name { 'User' }

    factory :user_with_authorships do
      transient do
        authorships_count { 10 }
      end

      after(:create) do |user, evaluator|
        create_list(:authorship, evaluator.authorships_count, user: user)
      end
    end

    factory :user_with_contracts do
      transient do
        contracts_count { 10 }
      end

      after(:create) do |user, evaluator|
        create_list(:user_contract, evaluator.contracts_count, user: user)
      end
    end

    factory :user_with_grants do
      transient do
        grants_count { 10 }
      end

      after(:create) do |user, evaluator|
        create_list(:researcher_fund, evaluator.grants_count, user: user)
      end
    end

    factory :user_with_presentations do
      transient do
        presentations_count { 10 }
      end

      after(:create) do |user, evaluator|
        create_list(:presentation_contribution, evaluator.presentations_count, user: user)
      end
    end

    factory :user_with_committee_memberships do
      transient do
        committee_memberships_count { 10 }
      end

      after(:create) do |user, evaluator|
        create_list(:committee_membership, evaluator.committee_memberships_count, user: user)
      end
    end

    factory :user_with_news_feed_items do
      transient do
        news_feed_items_count { 10 }
      end

      after(:create) do |user, evaluator|
        create_list(:news_feed_item, evaluator.news_feed_items_count, user: user)
      end
    end

    factory :user_with_organization_memberships do
      after(:create) do |user, _evaluator|
        create_list(:user_organization_membership, 3, user: user)
      end
    end

    factory :user_with_performances do
      transient do
        performances_count { 10 }
      end

      after(:create) do |user, evaluator|
        create_list(:user_performance, evaluator.performances_count, user: user)
      end
    end

    factory :sample_user do
      webaccess_id { FFaker::Lorem.characters(6) }
      first_name { FFaker::Name.first_name }
      last_name { FFaker::Name.last_name }
    end

    trait :with_psu_identity do
      psu_identity do
        {
          data: {
            userid: webaccess_id,
            givenName: 'Test',
            familyName: 'User',
            affiliation: ['FACULTY']
          }
        }
      end
      psu_identity_updated_at { Time.zone.now }
    end

    trait :with_psu_member_affiliation do
      psu_identity do
        {
          data: {
            userid: webaccess_id,
            givenName: 'Test',
            familyName: 'User',
            affiliation: ['MEMBER']
          }
        }
      end
      psu_identity_updated_at { Time.zone.now }
    end

    trait :with_inactive_psu_identity do
      psu_identity { nil }
      psu_identity_updated_at { Time.zone.now }
    end
  end
end
