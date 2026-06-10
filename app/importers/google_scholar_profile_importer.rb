# frozen_string_literal: true

require 'utilities/google_scholar_scraper'

class GoogleScholarProfileImporter
  def initialize(scraper: Utilities::GoogleScholarScraper.new,
                 matcher_class: GoogleScholarProfileMatcher,
                 refresh_days: ENV.fetch('REFRESH_DAYS', '120').to_i)
    @scraper = scraper
    @matcher_class = matcher_class
    @refresh_days = refresh_days
  end

  def call
    users = importable_users
    users = users.limit(ENV['LIMIT'].to_i) if ENV['LIMIT'].present?
    pbar = Utilities::ProgressBarTTY.create(
      title: 'Importing Google Scholar Profile Data',
      total: users.count
    )

    users.find_each do |user|
      if scraper.credit_budget_exceeded?
        Rails.logger.warn('GoogleScholarProfileImporter: credit budget exhausted, stopping run')
        break
      end

      import_user(user)
      pbar.increment
    end

    pbar.finish

    sleep 30
    Rails.logger.info("GoogleScholarProfileImporter: total ScraperAPI credits used: #{scraper.total_credits_used}")
  end

  private

    attr_reader :scraper, :matcher_class, :refresh_days

    def importable_users
      User.active
        .where('google_scholar_checked_at IS NULL OR google_scholar_checked_at < ?', refresh_days.days.ago)
        .where('google_scholar_id IS NOT NULL OR ai_google_scholar IS NOT NULL OR google_scholar_not_found = FALSE')
    end

    def import_user(user)
      scholar_id = user.google_scholar_id.presence || scholar_id_from_ai_url(user.ai_google_scholar)

      if scholar_id
        profile = scraper.fetch_profile(scholar_id)
        update_user(user, profile) if profile
      else
        import_by_discovery(user)
      end
    rescue StandardError => e
      Rails.logger.warn("GoogleScholarProfileImporter: failed to import user #{user.id}: #{e.message}")
    end

    def import_by_discovery(user)
      return if user.google_scholar_not_found?

      if user.publications.none?
        Rails.logger.info("GoogleScholarProfileImporter: skipping user #{user.id} — 0 publications, cannot match")
        return
      end

      profile = discover_profile(user)

      if profile
        update_user(user, profile)
      elsif !scraper.credit_budget_exceeded?
        user.update!(google_scholar_checked_at: Time.current, google_scholar_not_found: true)
      end
    end

    def discover_profile(user)
      scraper.search_profiles(profile_search_name(user)).each do |candidate|
        profile = scraper.fetch_profile(candidate[:scholar_id])
        next unless profile

        result = matcher_class.new(user, profile).match
        Rails.logger.info("GoogleScholarProfileImporter: #{result.message}")
        return profile if result.matched?
      end

      Rails.logger.info("GoogleScholarProfileImporter: no Google Scholar profile match for user #{user.id}")
      nil
    end

    def update_user(user, profile)
      updates = {
        google_scholar_id: user.google_scholar_id.presence || profile[:scholar_id],
        google_scholar_imported_at: Time.current,
        google_scholar_checked_at: Time.current,
        google_scholar_not_found: false
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
