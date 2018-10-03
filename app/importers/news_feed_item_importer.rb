require 'rss'
require 'open-uri'

class NewsFeedItemImporter

  # parse rss feeds from news.psu.edu
  def call
    selector = "//a[starts-with(@href, \"mailto:\")]/@href"
    rss_feeds = get_rss_feeds
    rss_feeds.each do |feed|
      rss = RSS::Parser.parse(open(feed).read, false).items
      rss.each do |result|
        puts result
        html_doc = Nokogiri::HTML(open(result.link))
        nodes = html_doc.xpath selector
        addresses = nodes.collect {|n| n.value[7..-1]}
        addresses.each do |a|
          if a.end_with?("psu.edu")
            if local_user(a) ==  true
              webaccess_id = a[0..-9]
              #puts webaccess_id
              u = User.find_by(webaccess_id: webaccess_id)

              nfi = NewsFeedItem.new(user:        u,
                                     title:       result.title,
                                     url:         result.link,
                                     pubdate:     result.pubDate,
                                     description: result.description)

              begin
                nfi.validate!
                nfi.save!
              rescue ActiveRecord::RecordNotUnique => e
              end
            end
          end
        end
      end

    end
  end

  private

  def local_user(q)
    users = User.pluck(:webaccess_id)
    if users.include? q[0..-9]
      true
    end
  end

  def get_rss_feeds
    return ['https://news.psu.edu/rss/topic/research', 'https://news.psu.edu/rss/topic/academic', 'https://news.psu.edu/rss/topic/impact', 'https://news.psu.edu/rss/topic/campus-life']
  end
end

