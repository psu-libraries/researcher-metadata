# frozen_string_literal: true

require 'component/component_spec_helper'
require 'rss'
require 'open-uri'

describe NewsFeedItemImporter do
  subject(:importer) { described_class.new }

  before do
    User.create(webaccess_id: 'abc123',
                first_name: 'Test',
                last_name: 'User')
    User.create(webaccess_id: 'def456',
                first_name: 'Test',
                last_name: 'McTester')
    User.create(webaccess_id: 'ghi789',
                first_name: 'Fuzzy',
                last_name: 'Matchman')
    User.create(webaccess_id: 'jkl987',
                first_name: 'Middle',
                middle_name: 'N',
                last_name: 'Test')
    User.create(webaccess_id: 'jkl654',
                first_name: 'Middle',
                last_name: 'Test')
  end

  let(:file) { fixture_file_upload('rss_output.xml') }

  describe '#call' do
    it 'populates database with news feed items' do
      allow_any_instance_of(described_class).to receive(:rss_feeds).and_return(['spec/fixtures/rss_output.xml'])
      importer.call
      expect(User.find_by(webaccess_id: 'abc123').news_feed_items.first.title).to eq('Title')
      expect(User.find_by(webaccess_id: 'def456').news_feed_items.first.title).to eq('Title')
      expect(User.find_by(webaccess_id: 'ghi789').news_feed_items.first.title).to eq('Title')
      expect(User.find_by(webaccess_id: 'jkl987').news_feed_items.first.title).to eq('Title')
      expect(User.find_by(webaccess_id: 'jkl654').news_feed_items.count).to eq(0)
      expect(NewsFeedItem.first.user.webaccess_id).to eq('abc123')
      expect(NewsFeedItem.first.published_on).to eq(Date.parse('Thu, 10 Oct 2013'))
      expect(NewsFeedItem.first.description).to eq('Description')
      expect(NewsFeedItem.second.user.webaccess_id).to eq('def456')
      expect(NewsFeedItem.second.published_on).to eq(Date.parse('Thu, 10 Oct 2013'))
      expect(NewsFeedItem.second.description).to eq('Description')
      expect(NewsFeedItem.count).to eq(4)
    end
  end

  it 'receives xml from rss in the proper format' do
    rss = RSS::Parser.parse(URI.open('https://news.psu.edu/rss/topic/research').read, false).items
    html_doc = Nokogiri::HTML(URI.open(rss[0].link))
    mailto_nodes = html_doc.xpath '//a[starts-with(@href, "mailto:")]/@href'
    tag_nodes = html_doc.xpath '//a[starts-with(@href, "/tag/")]/@href'
    expect(rss[0].link).not_to be_nil
    expect(rss[0].title).not_to be_nil
    expect(rss[0].pubDate).not_to be_nil
    # This fails frequently because items often don't have a description element
    # expect(rss[0].description).not_to be_nil
    expect(mailto_nodes).not_to be_nil
    expect(tag_nodes).not_to be_nil
  end

  context 'when there is an error retrieving a feed' do
    before do
      allow_any_instance_of(described_class).to receive(:rss_feeds)
        .and_return(['bad_url_raises_an_error', 'spec/fixtures/rss_output.xml'])

      allow(ImporterErrorLog).to receive(:log_error)
    end

    it 'logs the error' do
      importer.call

      expect(ImporterErrorLog).to have_received(:log_error).with(
        importer_class: described_class,
        error: an_instance_of(Errno::ENOENT),
        metadata: {
          feed: 'bad_url_raises_an_error'
        }
      )
    end

    it 'moves on to the next feed in the list' do
      expect { importer.call }.to change(NewsFeedItem, :count)
    end
  end

  context 'when there is an error parsing a feed' do
    before do
      allow_any_instance_of(described_class).to receive(:rss_feeds)
        .and_return(['spec/fixtures/rss_output.xml'])

      allow(ImporterErrorLog).to receive(:log_error)
      allow(User).to receive(:find_by).and_raise(ActiveRecord::RecordNotFound)
    end

    it 'logs the error' do
      importer.call
      expect(ImporterErrorLog).to have_received(:log_error).with(
        importer_class: described_class,
        error: an_instance_of(ActiveRecord::RecordNotFound),
        metadata: a_hash_including(
          feed: 'spec/fixtures/rss_output.xml',
          result: an_instance_of(String),
          html_doc: an_instance_of(String),
          mailto_ids: an_instance_of(Array),
          tag_names: nil
        )
      )
    end
  end
end
