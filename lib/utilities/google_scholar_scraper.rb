# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'
require 'time'

module Utilities
  class GoogleScholarScraper
    PAGE_SIZE = 100
    SCRAPE_CACHE_FILE = Rails.root.join('tmp/caches/scholar_scrape_cache.json').to_s
    PROFILE_CACHE_FILE = Rails.root.join('tmp/caches/scholar_profile_cache.json').to_s
    SCRAPE_MAX_COST = 35

    attr_reader :total_credits_used

    def initialize(api_key: ENV.fetch('SCRAPERAPI_KEY'),
                   refresh_days: ENV.fetch('REFRESH_DAYS', '120').to_i,
                   credit_budget: ENV.key?('CREDIT_BUDGET') ? ENV.fetch('CREDIT_BUDGET').to_i : nil)
      @api_key = api_key
      @refresh_days = refresh_days
      @credit_budget = credit_budget
      @total_credits_used = 0
    end

    def search_profiles(name)
      html = fetch_author_search_html(name)
      return [] unless html

      parse_profile_candidates(html)
    end

    def fetch_profile(scholar_id)
      if recently_scraped?(scholar_id)
        cached = cached_profile(scholar_id)
        return symbolize_profile(cached) if cached
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

      return unless profile_stats[:h_index].present? || papers.any?

      cache_profile(scholar_id, {
                      scholar_id: scholar_id,
                      h_index: profile_stats[:h_index],
                      citation_total: profile_stats[:citation_total],
                      publications: papers
                    })
    end

    def fetch_publication_by_doi(doi)
      normalized_doi = normalized_doi(doi)
      return unless normalized_doi

      html = fetch_scholar_search_html(normalized_doi)
      return unless html

      parse_doi_search_result(html, normalized_doi)
    end

    private

      attr_reader :api_key, :refresh_days, :credit_budget

      def fetch_author_search_html(name)
        scholar_url = 'https://scholar.google.com/citations?' \
                      "view_op=search_authors&mauthors=#{URI.encode_www_form_component(name)}&hl=en"

        fetch_scraperapi_html(scholar_url, "Google Scholar author search for #{name}")
      end

      def fetch_scholar_search_html(query)
        scholar_url = "https://scholar.google.com/scholar?q=#{URI.encode_www_form_component(query)}&hl=en"

        fetch_scraperapi_html(scholar_url, "Google Scholar publication search for #{query}")
      end

      def fetch_page_html(user_id, cstart)
        scholar_url = 'https://scholar.google.com/citations?' \
                      "user=#{user_id}&hl=en&sortby=citations&cstart=#{cstart}&pagesize=#{PAGE_SIZE}"

        fetch_scraperapi_html(scholar_url, "Scholar profile for #{user_id}")
      end

      def fetch_scraperapi_html(scholar_url, description)
        return nil if credit_budget_exceeded?

        uri = URI('https://api.scraperapi.com/')
        uri.query = URI.encode_www_form(
          api_key: api_key,
          url: scholar_url,
          country_code: 'us',
          render: 'true',
          max_cost: SCRAPE_MAX_COST
        )

        begin
          response = Net::HTTP.get_response(uri)
          @total_credits_used += response['sa-credit-cost'].to_i if response['sa-credit-cost']

          if response.code == '403' && response.body.include?('max_cost')
            Rails.logger.warn("Request rejected for #{description}: would exceed max_cost")
            return nil
          end

          return nil unless response.code == '200'

          response.body
        rescue Net::OpenTimeout, Net::ReadTimeout, SocketError => e
          Rails.logger.error("Network error fetching #{description}: #{e.message}")
          nil
        end
      end

      def credit_budget_exceeded?
        credit_budget && total_credits_used >= credit_budget
      end

      def parse_profile_candidates(html)
        doc = Nokogiri::HTML(html)

        doc.css('.gs_ai_chpr').filter_map do |profile|
          link = profile.at_css('.gs_ai_name a')
          scholar_id = scholar_id_from_href(link&.[]('href'))
          next unless scholar_id

          {
            scholar_id: scholar_id,
            name: link.text.strip,
            affiliation: profile.at_css('.gs_ai_aff')&.text&.strip,
            email_domain: profile.at_css('.gs_ai_eml')&.text&.strip,
            interests: profile.css('.gs_ai_one_int').map { |interest| interest.text.strip }
          }
        end
      end

      def scholar_id_from_href(href)
        return unless href

        URI.decode_www_form(URI.parse(href).query.to_s).find { |key, _value| key == 'user' }&.last
      rescue URI::InvalidURIError
        nil
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
          year_el = row.at_css('.gsc_a_y span')

          title = title_el ? title_el.text.strip : 'N/A'
          citations = cited_el ? cited_el.text.strip.to_i : 0
          detail_url = absolute_google_url(title_el&.[]('href'))
          year = year_el ? year_el.text.strip.to_i : nil

          papers << {
            title: title,
            citations: citations,
            year: year,
            doi: nil,
            detail_url: detail_url
          }
        end

        papers
      end

      def parse_doi_search_result(html, doi)
        doc = Nokogiri::HTML(html)

        doc.css('.gs_r.gs_or.gs_scl').each do |result|
          result_text = result.text.downcase
          next unless result_text.include?(doi.downcase)

          return {
            doi: doi,
            title: result.at_css('.gs_rt')&.text&.strip,
            citations: citation_count_from_result(result)
          }
        end

        nil
      end

      def citation_count_from_result(result)
        cited_by_link = result.css('.gs_fl a').find { |link| link.text.match?(/Cited by \d+/i) }
        return 0 unless cited_by_link

        cited_by_link.text[/\d+/].to_i
      end

      def absolute_google_url(href)
        return unless href

        URI.join('https://scholar.google.com', href).to_s
      end

      def recently_scraped?(scholar_id)
        cache = load_scrape_cache
        last_scraped = cache[scholar_id]
        return false unless last_scraped

        Time.now - Time.parse(last_scraped) < refresh_days * 24 * 60 * 60
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

        symbolize_profile(profile)
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

      def symbolize_profile(profile)
        {
          scholar_id: profile[:scholar_id] || profile['scholar_id'],
          h_index: profile[:h_index] || profile['h_index'],
          citation_total: profile[:citation_total] || profile['citation_total'],
          publications: symbolize_publications(profile[:publications] || profile['publications'])
        }
      end

      def symbolize_publications(publications)
        case publications
        when Hash
          publications.map do |title, citations|
            { title: title, citations: citations, year: nil, doi: nil, detail_url: nil }
          end
        when Array
          publications.map do |publication|
            {
              title: publication[:title] || publication['title'],
              citations: publication[:citations] || publication['citations'],
              year: publication[:year] || publication['year'],
              doi: publication[:doi] || publication['doi'],
              detail_url: publication[:detail_url] || publication['detail_url']
            }
          end
        else
          []
        end
      end

      def normalized_doi(value)
        value.to_s.downcase.match(%r{10\.\S+/\S+})&.[](0)&.delete_suffix('.')
      end
  end
end
