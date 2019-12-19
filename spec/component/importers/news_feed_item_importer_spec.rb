require 'component/component_spec_helper'
require 'rss'
require 'open-uri'

describe NewsFeedItemImporter do

  before(:each) do
    User.create( webaccess_id: "abc123",
                 first_name: "Test",
                 last_name: "User" )
    User.create( webaccess_id: "def456",
                 first_name: "Test",
                 last_name: "McTester")
  end

  subject(:importer){ NewsFeedItemImporter.new }
  let(:file) { fixture_file_upload('rss_output.xml') }
  let(:ldap_search_result) { [{ "uid" => "def456" }] }

  describe "#call" do
    it "populates database with news feed items" do
      allow_any_instance_of(NewsFeedItemImporter).to receive(:rss_feeds).and_return(["spec/fixtures/rss_output.xml"])
      allow_any_instance_of(Net::LDAP).to receive(:search).and_return(ldap_search_result)
      importer.call
      expect(User.find_by( webaccess_id: "abc123" ).news_feed_items.first.title).to eq("Title")
      expect(User.find_by( webaccess_id: "def456" ).news_feed_items.first.title).to eq("Title")
      expect(NewsFeedItem.first.user.webaccess_id).to eq("abc123")
      expect(NewsFeedItem.first.published_on).to eq(Date.parse("Thu, 10 Oct 2013"))
      expect(NewsFeedItem.first.description).to eq("Description")
      expect(NewsFeedItem.second.user.webaccess_id).to eq("def456")
      expect(NewsFeedItem.second.published_on).to eq(Date.parse("Thu, 10 Oct 2013"))
      expect(NewsFeedItem.second.description).to eq("Description")
      expect(NewsFeedItem.count).to eq(2)
    end
  end

  it "receives xml from rss in the proper format" do
    rss = RSS::Parser.parse(open('https://news.psu.edu/rss/topic/research').read, false).items
    html_doc = Nokogiri::HTML(open(rss[0].link))
    mailto_nodes = html_doc.xpath "//a[starts-with(@href, \"mailto:\")]/@href"
    tag_nodes = html_doc.xpath "//a[starts-with(@href, \"/tag/\")]/@href"
    expect(rss[0].link).not_to be_nil
    expect(rss[0].title).not_to be_nil
    expect(rss[0].pubDate).not_to be_nil
    expect(rss[0].description).not_to be_nil
    expect(mailto_nodes).not_to be_nil
    expect(tag_nodes).not_to be_nil
  end

end

