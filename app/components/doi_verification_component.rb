# frozen_string_literal: true

class DOIVerificationComponent < ViewComponent::Base
  def publication_display_limit
    100
  end

  def publications
    Publication.doi_unverified.first(publication_display_limit)
  end

  def doi_verification_display(publication)
    if publication.doi_check == false
      'Failed Verification'
    else
      'Unchecked'
    end 
  end

  def page_count
    publications.count > publication_display_limit ? 
        "Showing #{publication_display_limit} of #{publications.count} publications" : 
        "Showing #{publications.count} of #{publications.count} publications"
  end
end
