# frozen_string_literal: true

class DoiVerificationJob < ApplicationJob
  def perform(publication)
    return if publication.doi_verified == true

    if publication.doi.present?
      DoiVerificationService.new(publication).verify
    else
      response = UnpaywallClient.query_unpaywall(publication)
      if publication.matchable_title == response.matchable_title && response.doi.present?
        publication.update!(doi: response.doi, doi_verified: true)
      end
    end
  end
end
