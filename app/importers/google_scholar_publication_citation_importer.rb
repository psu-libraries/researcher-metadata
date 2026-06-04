# frozen_string_literal: true

require 'utilities/google_scholar_scraper'

class GoogleScholarPublicationCitationImporter
  def initialize(scraper: Utilities::GoogleScholarScraper.new)
    @scraper = scraper
  end

  def call
    publications = Publication.where.not(doi: [nil, ''])
    pbar = Utilities::ProgressBarTTY.create(
      title: 'Importing Google Scholar Publication Citations',
      total: publications.count
    )

    publications.find_each do |publication|
      import_publication(publication)
      pbar.increment
    end

    pbar.finish
  end

  private

    attr_reader :scraper

    def import_publication(publication)
      result = scraper.fetch_publication_by_doi(publication.doi)
      return unless result

      publication.update!(google_scholar_citation_count: result[:citations])
    rescue StandardError => e
      Rails.logger.warn(
        "GoogleScholarPublicationCitationImporter: failed to import publication #{publication.id}: #{e.message}"
      )
    end
end
