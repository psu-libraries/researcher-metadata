FactoryBot.define do
  factory :news_feed_item do
    user { create :user }
    title { 'Test' }
    sequence(:url) { |n| "www.test.com/news#{n}" }
    pubdate { '2018-10-01' }
    description { 'Test description' }
  end
end

