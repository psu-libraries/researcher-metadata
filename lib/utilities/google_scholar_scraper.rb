# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'
require 'time'

class GoogleScholarScraper
  API_KEY = ENV.fetch('SCRAPERAPI_KEY')

  PAGE_SIZE = 100
  SCRAPE_CACHE_FILE = Rails.root.join('tmp/caches/scholar_scrape_cache.json').to_s
  PROFILE_CACHE_FILE = Rails.root.join('tmp/caches/scholar_profile_cache.json').to_s
  NO_PROFILE = '__no_profile__'
  REFRESH_DAYS = ENV.fetch('REFRESH_DAYS', '120').to_i
  CREDIT_BUDGET = ENV.key?('CREDIT_BUDGET') ? ENV.fetch('CREDIT_BUDGET').to_i : nil
  SCRAPE_MAX_COST = 35

  attr_reader :total_credits_used

  def initialize
    @total_credits_used = 0
  end

  def call
    # Placeholder for orchestration - will be implemented by GoogleScholarImporter
    raise NotImplementedError, 'Use GoogleScholarImporter.new.call instead'
  end

  def fetch_profile(scholar_id)
    if recently_scraped?(scholar_id)
      cached = cached_profile(scholar_id)
      return cached if cached
    end

    papers = []
    profile_stats = { h_index: nil, citation_total: nil }
    cstart = 0

    loop do
      html = fetch_page_html(scholar_id, cstart)
      break unless html

      profile_stats = parse_profile_stats(html) if cstart.zero?
      page_papers = parse_papers(html)
      papers.concat(page_papers)

      break if page_papers.length < PAGE_SIZE

      cstart += PAGE_SIZE
      sleep 2
    end

    cache_profile(scholar_id, {
                    scholar_id: scholar_id,
                    h_index: profile_stats[:h_index],
                    citation_total: profile_stats[:citation_total],
                    publications: papers.each_with_object({}) { |p, h| h[p[:title]] = p[:citations] }
                  })
  end

  private

    def fetch_page_html(user_id, cstart)
      scholar_url = "https://scholar.google.com/citations?user=#{user_id}&hl=en&sortby=citations&cstart=#{cstart}&pagesize=#{PAGE_SIZE}"

      uri = URI('https://api.scraperapi.com/')
      uri.query = URI.encode_www_form(
        api_key: API_KEY,
        url: scholar_url,
        country_code: 'us',
        render: 'true',
        max_cost: SCRAPE_MAX_COST
      )

      begin
        response = Net::HTTP.get_response(uri)
        @total_credits_used += response['sa-credit-cost'].to_i if response['sa-credit-cost']

        if response.code == '403' && response.body.include?('max_cost')
          Rails.logger.warn("Request rejected for #{user_id}: would exceed max_cost")
          return nil
        end

        return nil unless response.code == '200'

        response.body
      rescue Net::OpenTimeout, Net::ReadTimeout, SocketError => e
        Rails.logger.error("Network error fetching Scholar profile for #{user_id}: #{e.message}")
        nil
      end
    end

    def parse_profile_stats(html)
      doc = Nokogiri::HTML(html)
      h_index = nil
      citation_total = nil

      doc.css('#gsc_rsb_st tr').each do |row|
        label = row.at_css('.gsc_rsb_sc1')&.text&.strip
        values = row.css('.gsc_rsb_std')
        first_value = values.first&.text&.strip

        if label == 'Citations'
          citation_total = first_value&.to_i
        elsif label == 'h-index'
          h_index = first_value&.to_i
        end
      end

      { h_index: h_index, citation_total: citation_total }
    end

    def parse_papers(html)
      doc = Nokogiri::HTML(html)
      papers = []

      doc.css('#gsc_a_b .gsc_a_tr').each do |row|
        title_el = row.at_css('.gsc_a_at')
        cited_el = row.at_css('.gsc_a_ac')

        title = title_el ? title_el.text.strip : 'N/A'
        citations = cited_el ? cited_el.text.strip.to_i : 0

        papers << { title: title, citations: citations }
      end

      papers
    end

    def recently_scraped?(scholar_id)
      cache = load_scrape_cache
      last_scraped = cache[scholar_id]
      return false unless last_scraped

      Time.now - Time.parse(last_scraped) < REFRESH_DAYS * 24 * 60 * 60
    rescue ArgumentError
      false
    end

    def cached_profile(scholar_id)
      profile_cache = load_profile_cache
      profile_cache[scholar_id]
    end

    def cache_profile(scholar_id, profile)
      timestamp_cache = load_scrape_cache
      timestamp_cache[scholar_id] = Time.now.utc.iso8601
      save_scrape_cache(timestamp_cache)

      profile_cache = load_profile_cache
      profile_cache[scholar_id] = profile
      save_profile_cache(profile_cache)

      profile
    end

    def load_profile_cache
      return {} unless File.exist?(PROFILE_CACHE_FILE)

      JSON.parse(File.read(PROFILE_CACHE_FILE, encoding: 'UTF-8'))
    rescue JSON::ParserError
      {}
    end

    def save_profile_cache(cache)
      File.write(PROFILE_CACHE_FILE, JSON.pretty_generate(cache))
    end

    def load_scrape_cache
      return {} unless File.exist?(SCRAPE_CACHE_FILE)

      JSON.parse(File.read(SCRAPE_CACHE_FILE, encoding: 'UTF-8'))
    rescue JSON::ParserError
      {}
    end

    def save_scrape_cache(cache)
      File.write(SCRAPE_CACHE_FILE, JSON.pretty_generate(cache))
    end
end
