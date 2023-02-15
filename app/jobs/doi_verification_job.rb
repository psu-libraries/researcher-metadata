# frozen_string_literal: true

class DoiVerificationJob < ApplicationJob
  queue_as 'default'

  def perform(publication_id)
    publication = Publication.find(publication_id)
    return if publication.doi_verified == true

    if publication.doi.present?
      DoiVerificationService.new(publication).verify
    else
      response = UnpaywallClient.query_unpaywall(publication)
      if publication.matchable_title == response.matchable_title && response.doi.present?
        publication.update!(doi: response.doi, doi_verified: true)
      else
        publication.update!(doi_verified: false)
      end
    end
  end
end
