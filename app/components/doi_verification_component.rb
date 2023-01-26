# frozen_string_literal: true

class DOIVerificationComponent < ViewComponent::Base
  def publications
    Publication.doi_unverified
  end

  def doi_verification_display(publication)
    if publication.doi_verified == false
      'Failed Verification'
    elsif publication.doi_verified.nil?
      'Unchecked'
    end
  end
end
