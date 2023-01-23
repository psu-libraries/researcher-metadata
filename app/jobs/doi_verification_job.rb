# frozen_string_literal: true

class DoiVerificationJob
  def perform(publication)
    if publication.doi.present?
      DoiVerificationService.new(publication).verify
    else
      doi = UnpaywallClient.new.query_unpaywall(publication).doi
      publication.update!(doi: doi, doi_verified: true) if doi.present?
  end
end
