# frozen_string_literal: true

class DoiVerificationJob
  def perform(publication)
    DoiVerificationService.new(publication).verify unless publication.doi.blank?
  end
end