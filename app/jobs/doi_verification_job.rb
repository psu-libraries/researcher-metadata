# frozen_string_literal: true

class DoiVerificationJob
  def perform(publication)
    DoiVerificationService.new(publication).verify if publication.doi.present?
  end
end
