# frozen_string_literal: true

class GoogleScholarImporter
  def call
    users = User.active.where.not(google_scholar_id: nil)
    scraper = GoogleScholarScraper.new

    pbar = Utilities::ProgressBarTTY.create(
      title: 'Importing Google Scholar Data',
      total: users.count
    )

    users.find_each do |user|
      import_user(user, scraper)
      pbar.increment
    end

    pbar.finish
  end

  private

    def import_user(user, scraper)
      profile = scraper.fetch_profile(user.google_scholar_id)
      return unless profile

      user.update!(
        google_scholar_h_index: profile[:h_index],
        google_scholar_citation_total: profile[:citation_total],
        google_scholar_imported_at: Time.current
      )

      publications = profile[:publications] || profile['publications'] || {}
      publications.each do |title, citation_count|
        import_publication(title, citation_count)
      end
    rescue StandardError => e
      Rails.logger.warn("GoogleScholarImporter: failed to import user #{user.id}: #{e.message}")
    end

    def import_publication(title, citation_count)
      pub = find_matching_publication(title)
      return unless pub

      pub.update!(google_scholar_citation_count: citation_count)
    rescue StandardError => e
      Rails.logger.warn("GoogleScholarImporter: failed to update publication '#{title}': #{e.message}")
    end

    def find_matching_publication(title)
      Publication.find_each.find do |pub|
        PublicationFuzzyMatcher.new(pub).match?(title)
      end
    end
end
