require 'component/component_spec_helper'
require 'rss'
require 'open-uri'

describe NewsFeedItemImporter do

  before(:each) do
    User.create( webaccess_id: "abc123",
                 first_name: "Test",
                 last_name: "User" )
  end

  subject(:importer){ NewsFeedItemImporter.new }
  let(:file) { fixture_file_upload('rss_output.xml') }

  describe "#call" do
    it "populates database with news feed items" do
      allow_any_instance_of(NewsFeedItemImporter).to receive(:rss_feeds).and_return(["spec/fixtures/rss_output.xml"])
      importer.call
      expect(User.find_by( webaccess_id: "abc123" ).news_feed_items.first.title).to eq("Title")
      expect(NewsFeedItem.find_by(url: "spec/fixtures/rss_html.html").user.webaccess_id).to eq("abc123")
      expect(NewsFeedItem.find_by(url: "spec/fixtures/rss_html.html").published_on).to eq(Date.parse("Thu, 10 Oct 2013"))
      expect(NewsFeedItem.find_by(url: "spec/fixtures/rss_html.html").description).to eq("Description")
    end
  end

  it "receives xml from rss in the proper format" do
    rss = RSS::Parser.parse(open('https://news.psu.edu/rss/topic/research').read, false).items
    html_doc = Nokogiri::HTML(open(rss[0].link))
    nodes = html_doc.xpath "//a[starts-with(@href, \"mailto:\")]/@href"
    expect(rss[0].link).not_to be_nil
    expect(rss[0].title).not_to be_nil
    expect(rss[0].pubDate).not_to be_nil
    expect(rss[0].description).not_to be_nil
    expect(nodes).not_to be_nil
  end

end

