require 'rss'
require 'open-uri'

class NewsFeedItemImporter

  # parse rss feeds from news.psu.edu
  def call
    rss_feeds.each do |feed|
      rss = RSS::Parser.parse(open(feed).read, false).items
      rss.each do |result|
        html_doc = Nokogiri::HTML(open(result.link))
        mailto_ids = get_access_ids_from_mailto_selector(html_doc)
        tag_ids = get_access_ids_from_tag_selector(html_doc)
        access_ids = gather_access_ids(mailto_ids, tag_ids)
        access_ids.each do |a|
          if local_user?(a)
            u = User.find_by(webaccess_id: a)

            NewsFeedItem.find_or_create_by(user_id: u.id, url: result.link) do |n|
              n.user = u
              n.title = result.title
              n.url = result.link
              n.published_on = result.pubDate
              n.description = result.description
            end
          end
        end
      end

    end
  end

  private

  def gather_access_ids(*args)
    args.flatten.compact
  end

  def get_access_ids_from_mailto_selector(html_doc)
    mailto_selector = "//a[starts-with(@href, \"mailto:\")]/@href"
    mailto_nodes = html_doc.xpath mailto_selector
    mailto_addresses = mailto_nodes.collect {|n| n.value[7..-1]}
    mailto_addresses.collect {|n| n[0..-9] if n.end_with?("psu.edu")}
  end

  def get_access_ids_from_tag_selector(html_doc)
    names = []
    tag_selector = "//a[starts-with(@href, \"/tag/\")]/@href"
    tag_nodes = html_doc.xpath tag_selector
    tag_nodes.each do |node|
      name = node.value.gsub('/tag/', '').split('-')
      next if name.length > 3 || name.length < 2

      name.delete_at(1) if name.length == 3
      names << name
    end
    get_access_ids_from_ldap(names)
  end

  def get_access_ids_from_ldap(names)
    access_ids = []
    ldap ||= Net::LDAP.new(host: 'dirapps.aset.psu.edu', port: 389)
    names.each do |name|
      filter = Net::LDAP::Filter.eq('givenname', name[0]) & Net::LDAP::Filter.eq('sn', name[1])
      entry = ldap.search(base: 'dc=psu,dc=edu', filter: filter).first
      next if entry.blank?

      access_ids << entry["uid"]
    end
    access_ids
  end

  def local_user?(q)
    users = User.pluck(:webaccess_id)
    if users.include? q
      true
    end
  end

  def rss_feeds
    ['https://news.psu.edu/rss/topic/research', 'https://news.psu.edu/rss/topic/academics', 'https://news.psu.edu/rss/topic/impact', 'https://news.psu.edu/rss/topic/campus-life']
  end
end

