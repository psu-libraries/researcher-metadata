# frozen_string_literal: true

class DOIVerificationJob < ApplicationJob
  queue_as 'default'

  def perform(publication_id)
    publication = Publication.find(publication_id)
    return if publication.doi_verified == true

    unpaywall_response = nil

    if publication.doi.present?
      DOIVerificationService.new(publication).verify
    else
      unpaywall_response = UnpaywallClient.query_unpaywall(publication)
      if publication.matchable_title == unpaywall_response.matchable_title && unpaywall_response.doi.present?
        publication.update!(doi: unpaywall_response.doi, doi_verified: true)
      else
        publication.update!(doi_verified: false)
      end
    end

    sleep 1 unless Rails.env.test?
  rescue StandardError => e
    ImporterErrorLog.log_error(
      importer_class: self.class,
      error: e,
      metadata: {
        publication_id: publication&.id,
        publication_doi_url_path: publication&.doi_url_path,
        unpaywall_response: unpaywall_response.to_s
      }
    )
  end
end
