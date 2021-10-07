require 'component/component_spec_helper'

describe API::V1::NewsFeedItemSerializer do
  let(:user) { create :user, webaccess_id: 'abc123' }
  let(:news_feed_item) { create :news_feed_item,
                                user: user,
                                title: 'news feed item 1',
                                url: 'www.test.com/news1',
                                published_on: Date.new(2018, 10, 1),
                                description: 'news feed description 1' }

  describe 'data attributes' do
    subject { serialized_data_attributes(news_feed_item) }

    it { is_expected.to include(title: 'news feed item 1') }
    it { is_expected.to include(url: 'www.test.com/news1') }
    it { is_expected.to include(published_on: '2018-10-01') }
    it { is_expected.to include(description: 'news feed description 1') }
  end
end
