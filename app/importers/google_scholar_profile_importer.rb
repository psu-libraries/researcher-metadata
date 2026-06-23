# frozen_string_literal: true

require 'utilities/google_scholar_scraper'
require 'utilities/google_scholar_url'

class GoogleScholarProfileImporter
  include Utilities::GoogleScholarURL

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
      import_user(user)
      pbar.increment
    end

    pbar.finish

    Rails.logger.info("GoogleScholarProfileImporter: total ScraperAPI credits used: #{scraper.total_credits_used}")
  end

  private

    attr_reader :scraper, :matcher_class, :refresh_days

    def importable_users
      User.active.needs_google_scholar_refresh(refresh_days.days.ago)
    end

    def import_user(user)
      scholar_id = user.google_scholar_id.presence || scholar_id_from_url(user.ai_google_scholar)

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

      result = discover_profile(user)

      if result.is_a?(Hash)
        update_user(user, result)
      elsif result != :scraper_error
        user.update!(google_scholar_checked_at: Time.current, google_scholar_not_found: true)
      end
    end

    def discover_profile(user)
      candidates = scraper.search_profiles(profile_search_name(user))

      if candidates.nil?
        Rails.logger.warn("GoogleScholarProfileImporter: skipping user #{user.id} — ScraperAPI error during search")
        return :scraper_error
      end

      scraper_error = false

      candidates.each do |candidate|
        partial = scraper.fetch_profile_page0(candidate[:scholar_id])
        if partial == :scraper_error
          scraper_error = true
          next
        end
        next unless partial

        result = matcher_class.new(user, partial).match
        Rails.logger.info("GoogleScholarProfileImporter: #{result.message}")
        next unless result.matched?

        full_profile = scraper.fetch_profile(candidate[:scholar_id])
        return :scraper_error unless full_profile

        return full_profile
      end

      return :scraper_error if scraper_error

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

    def profile_search_name(user)
      [user.first_name, user.last_name].compact_blank.join(' ')
    end
end
