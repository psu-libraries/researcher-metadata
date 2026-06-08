# frozen_string_literal: true

require 'utilities/google_scholar_scraper'

class GoogleScholarProfileImporter
  def initialize(scraper: Utilities::GoogleScholarScraper.new, matcher_class: GoogleScholarProfileMatcher)
    @scraper = scraper
    @matcher_class = matcher_class
  end

  def call
    users = User.active
    users = users.limit(ENV['LIMIT'].to_i) if ENV['LIMIT'].present?
    pbar = Utilities::ProgressBarTTY.create(
      title: 'Importing Google Scholar Profile Data',
      total: users.count
    )

    users.find_each do |user|
      import_user(user)
      pbar.increment
    end

    pbar.finish

    sleep 30
    Rails.logger.info("GoogleScholarProfileImporter: total ScraperAPI credits used: #{scraper.total_credits_used}")
  end

  private

    attr_reader :scraper, :matcher_class

    def import_user(user)
      profile = if user.google_scholar_id.present?
                  scraper.fetch_profile(user.google_scholar_id)
                elsif (id = scholar_id_from_ai_url(user.ai_google_scholar))
                  scraper.fetch_profile(id)
                else
                  discover_profile(user)
                end
      return unless profile

      update_user(user, profile)
    rescue StandardError => e
      Rails.logger.warn("GoogleScholarProfileImporter: failed to import user #{user.id}: #{e.message}")
    end

    def discover_profile(user)
      if user.publications.none?
        Rails.logger.info("GoogleScholarProfileImporter: skipping user #{user.id} — 0 publications, cannot match")
        return nil
      end

      scraper.search_profiles(profile_search_name(user)).each do |candidate|
        profile = scraper.fetch_profile(candidate[:scholar_id])
        next unless profile

        result = matcher_class.new(user, profile).match
        if result.matched?
          Rails.logger.info("GoogleScholarProfileImporter: #{result.message}")
          return profile
        end

        Rails.logger.info("GoogleScholarProfileImporter: #{result.message}")
      end

      Rails.logger.info("GoogleScholarProfileImporter: no Google Scholar profile match for user #{user.id}")
      nil
    end

    def update_user(user, profile)
      updates = {
        google_scholar_id: user.google_scholar_id.presence || profile[:scholar_id],
        google_scholar_imported_at: Time.current
      }

      updates[:google_scholar_h_index] = profile[:h_index] if profile[:h_index].present?
      updates[:google_scholar_citation_total] = profile[:citation_total] if profile[:citation_total].present?

      user.update!(updates)
    end

    def scholar_id_from_ai_url(url)
      return if url.blank?

      URI.decode_www_form(URI.parse(url).query.to_s).find { |key, _| key == 'user' }&.last
    rescue URI::InvalidURIError
      nil
    end

    def profile_search_name(user)
      [user.first_name, user.middle_name, user.last_name].compact_blank.join(' ')
    end
end
