FactoryBot.define do
  factory :user do
    sequence :webaccess_id do |n|
      "abc#{n}"
    end
    first_name { 'Test' }
    last_name { 'User' }

    factory :user_with_authorships do
      transient do
        authorships_count 10
      end

      after(:create) do |user, evaluator|
        create_list(:authorship, evaluator.authorships_count, user: user)
      end
    end

    factory :user_with_contracts do
      transient do
        contracts_count 10
      end

      after(:create) do |user, evaluator|
        create_list(:user_contract, evaluator.contracts_count, user: user)
      end
    end

    factory :user_with_news_feed_items do
      transient do
        contracts_count 10
      end

      after(:create) do |user, evaluator|
        create_list(:news_feed_item, evaluator.news_feed_item_count, user: user)
      end
    end
  end
end
