# frozen_string_literal: true

require 'string/similarity'

class DOIVerificationService
  attr_reader :publication

  def initialize(publication)
    @publication = publication
  end

  def verify
    pub_title = publication.matchable_title
    unpaywall_title = UnpaywallClient.query_unpaywall(publication).matchable_title
    publication.doi_verified = compare_title(pub_title, unpaywall_title)
    publication.save!
  end

  private

    def compare_title(pub_title, unpaywall_title)
      distance = String::Similarity.levenshtein_distance(pub_title, unpaywall_title)
      longer_string = [pub_title.length, unpaywall_title.length].max
      similarity = (longer_string - distance) / longer_string.to_f
      return false unless similarity > 0.7

      true
    end
end
