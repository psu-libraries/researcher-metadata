# frozen_string_literal: true

class DoiVerificationJob
  def perform(publication)
    return if publication.doi_verified == true

    if publication.doi.present?
      DoiVerificationService.new(publication).verify
    else
      response = UnpaywallClient.new.query_unpaywall(publication)
      if publication.title&.downcase&.gsub(/[^a-z0-9]/, '') == response.title&.downcase&.gsub(/[^a-z0-9]/, '') && response.doi.present?
        publication.update!(doi: DOISanitizer.new(response.doi).url, doi_verified: true)
      end
    end
  end
end
