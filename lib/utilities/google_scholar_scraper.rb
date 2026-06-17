# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'
require 'string/similarity'
require 'utilities/google_scholar_url'

module Utilities
  class GoogleScholarScraper
    include GoogleScholarURL

    PAGE_SIZE = 100
    SCRAPE_MAX_COST = 35
    CANDIDATE_NAME_SIMILARITY_THRESHOLD = 0.75

    attr_reader :total_credits_used

    def initialize(api_key: ENV.fetch('SCRAPERAPI_KEY'),
                   credit_budget: ENV.key?('CREDIT_BUDGET') ? ENV.fetch('CREDIT_BUDGET').to_i : nil)
      @api_key = api_key
      @credit_budget = credit_budget
      @total_credits_used = 0
    end

    def search_profiles(name)
      data = fetch_structured_google_search(name)
      return nil if data.nil?

      parse_structured_search_candidates(data, name)
    end

    def fetch_profile(scholar_id)
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

      {
        scholar_id: scholar_id,
        h_index: profile_stats[:h_index],
        citation_total: profile_stats[:citation_total],
        email_domain: profile_stats[:email_domain],
        affiliation: profile_stats[:affiliation],
        publications: papers
      }
    end

    def fetch_publication_by_doi(doi)
      normalized_doi = normalized_doi(doi)
      return unless normalized_doi

      html = fetch_scholar_search_html(normalized_doi)
      return unless html

      parse_doi_search_result(html, normalized_doi)
    end

    def credit_budget_exceeded?
      credit_budget.present? && total_credits_used >= credit_budget
    end

    private

      attr_reader :api_key, :credit_budget

      def fetch_scholar_search_html(query)
        scholar_url = "https://scholar.google.com/scholar?q=#{URI.encode_www_form_component(query)}&hl=en"

        fetch_scraperapi_html(scholar_url, "Google Scholar publication search for #{query}")
      end

      def fetch_page_html(user_id, cstart)
        scholar_url = 'https://scholar.google.com/citations?' \
                      "user=#{user_id}&hl=en&sortby=citations&cstart=#{cstart}&pagesize=#{PAGE_SIZE}"

        fetch_scraperapi_html(scholar_url, "Scholar profile for #{user_id}")
      end

      def fetch_scraperapi_html(scholar_url, description, render: true)
        return nil if credit_budget_exceeded?

        uri = URI('https://api.scraperapi.com/')
        uri.query = URI.encode_www_form(
          api_key: api_key,
          url: scholar_url,
          country_code: 'us',
          render: render.to_s,
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

      def name_token_matches?(title, name_part)
        title.split.any? { |word| String::Similarity.cosine(word, name_part) >= CANDIDATE_NAME_SIMILARITY_THRESHOLD }
      end

      def fetch_structured_google_search(name)
        return nil if credit_budget_exceeded?

        query = "#{name} psu.edu site:scholar.google.com/citations"
        uri = URI('https://api.scraperapi.com/structured/google/search/v1')
        uri.query = URI.encode_www_form(api_key: api_key, query: query, country_code: 'us')

        begin
          response = Net::HTTP.get_response(uri)
          @total_credits_used += response['sa-credit-cost'].to_i if response['sa-credit-cost']
          unless response.code == '200'
            Rails.logger.warn("Structured Google search failed with HTTP #{response.code} for #{name}")
            return nil
          end

          JSON.parse(response.body)
        rescue Net::OpenTimeout, Net::ReadTimeout, SocketError => e
          Rails.logger.error("Network error fetching Google Scholar search for #{name}: #{e.message}")
          nil
        rescue JSON::ParserError
          Rails.logger.error("Invalid JSON from Google structured search for #{name}")
          nil
        end
      end

      def parse_structured_search_candidates(data, name)
        name_parts = name.to_s.downcase.split
        first = name_parts.first
        last = name_parts.last
        return [] unless first && last

        (data['organic_results'] || []).filter_map do |result|
          link = result['link'].to_s
          next unless link.include?('scholar.google.com/citations') && link.include?('user=')

          title = result['title'].to_s.downcase
          next unless name_token_matches?(title, first) && name_token_matches?(title, last)

          scholar_id = scholar_id_from_url(link)
          next unless scholar_id

          { scholar_id: scholar_id }
        end.uniq { |c| c[:scholar_id] }
      end

      def parse_profile_stats(html)
        doc = Nokogiri::HTML(html)
        h_index = nil
        citation_total = nil
        email_domain = nil
        affiliation = nil

        doc.css('#gsc_rsb_st tr').each do |row|
          label = row.at_css('.gsc_rsb_sc1')&.text&.strip
          first_value = row.css('.gsc_rsb_std').first&.text&.strip

          if label == 'Citations'
            citation_total = first_value&.to_i
          elsif label == 'h-index'
            h_index = first_value&.to_i
          end
        end

        affiliation_div = doc.at_css('#gsc_prf_ivh')
        if affiliation_div
          div_text = affiliation_div.text
          email_match = div_text.match(/Verified email at (\S+)/i)
          email_domain = email_match[1].sub(/[.,;]+$/, '') if email_match
          affiliation = affiliation_div.children.find(&:text?)&.text&.strip.presence
        end

        { h_index: h_index, citation_total: citation_total, email_domain: email_domain, affiliation: affiliation }
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

      def normalized_doi(value)
        value.to_s.downcase.match(%r{10\.\S+/\S+})&.[](0)&.delete_suffix('.')
      end
  end
end
