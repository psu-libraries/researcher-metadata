# frozen_string_literal: true

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
        mailto_ids.each do |a|
          u = User.find_by(webaccess_id: a)
          next if u.blank?

          find_or_create_news_feed_item(u, result)
        end
        tag_names = get_names_from_tag_selector(html_doc)
        tag_names.each do |name|
          mu = matched_users(name)
          next if mu.blank?

          mu.each do |user|
            find_or_create_news_feed_item(user, result)
          end
        end
      rescue StandardError => e
        log_error(e, {
                    feed: feed.to_s,
                    result: result.to_s,
                    html_doc: binding.local_variable_get(:html_doc).to_s,
                    mailto_ids: binding.local_variable_get(:mailto_ids),
                    tag_names: binding.local_variable_get(:tag_names)
                  })
      end

    rescue StandardError => e
      log_error(e, { feed: feed })
    end
  end

  private

    def get_access_ids_from_mailto_selector(html_doc)
      mailto_selector = '//a[starts-with(@href, "mailto:")]/@href'
      mailto_nodes = html_doc.xpath mailto_selector
      mailto_addresses = mailto_nodes.map { |n| n.value[7..] }
      mailto_addresses.map { |n| n[0..-9] if n.end_with?('psu.edu') }.flatten.compact
    end

    def get_names_from_tag_selector(html_doc)
      names = []
      tag_selector = '//a[starts-with(@href, "/tag/")]/@href'
      tag_nodes = html_doc.xpath tag_selector
      tag_nodes.each do |node|
        name = node.value.gsub('/tag/', '').split('-')
        next if name.length > 3 || name.length < 2

        name.insert(1, '') if name.length == 2
        names << name
      end
      names
    end

    def matched_users(name)
      u = User.where('similarity(lower(first_name), ?) > 0.35 AND lower(last_name) = ?', name[0].downcase, name[2].downcase)
      return u if u.count == 1 || u.blank?

      u_final = u.where('lower(middle_name) = ?', name[1].downcase)
      return u_final if name[1].blank?

      u_final = u.where('lower(left(middle_name, 1)) = ?', name[1][0].downcase) if u_final.blank?
      return u if u_final.blank?

      u_final
    end

    def find_or_create_news_feed_item(user, rss_result)
      NewsFeedItem.find_or_create_by(user_id: user.id, url: rss_result.link) do |n|
        n.user = user
        n.title = rss_result.title
        n.url = rss_result.link
        n.published_on = rss_result.pubDate
        n.description = rss_result.description
      end
    end

    def rss_feeds
      ['https://news.psu.edu/rss/topic/research', 'https://news.psu.edu/rss/topic/academics', 'https://news.psu.edu/rss/topic/impact', 'https://news.psu.edu/rss/topic/campus-life']
    end

    def log_error(err, metadata)
      ImporterErrorLog.log_error(
        importer_class: self.class,
        error: err,
        metadata: metadata
      )
    end
end
