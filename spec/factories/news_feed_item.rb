FactoryBot.define do
  factory :news_feed_item do
    user { create :user }
    title { 'Test' }
    sequence(:url) { |n| "www.test.com/news#{n}" }
    description { 'Test description' }
  end
end

