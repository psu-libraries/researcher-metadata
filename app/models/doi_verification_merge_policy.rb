# frozen_string_literal: true

class DoiVerificationMergePolicy
  def initialize(publications)
    @publications = publications
  end

  def doi_verification_to_keep
    unverified = nil
    publications.each do |pub|
      return true if pub.doi_verified == true

      unverified = true if pub.doi_verified == false
    end

    return false if unverified

    nil
  end

  private

    attr_accessor :publications
end
