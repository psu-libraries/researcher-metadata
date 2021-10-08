# frozen_string_literal: true

require 'component/component_spec_helper'

describe 'the news_feed_item table', type: :model do
  subject { NewsFeedItem.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:user_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:title).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:url).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:description).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:published_on).of_type(:date).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index([:url, :user_id]).unique(true) }
end

describe NewsFeedItem, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:published_on) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end
end
