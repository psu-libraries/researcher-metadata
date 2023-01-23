# frozen_string_literal: true

require 'string/similarity'

class DoiVerificationService
  attr_reader :publication

  def initialize(publication)
    @publication = publication
  end

  def verify
    pub_title = publication.title + publication.secondary_title.to_s
    unpaywall_title = UnpaywallClient.new.query_unpaywall(publication).title
    publication.doi_verified = compare_title(pub_title, unpaywall_title)
    publication.save!
  end

  private

  def compare_title(pub_title, unpaywall_title)
    title1 = pub_title.delete(" \t\r\n:,'\"").downcase
    title2 = unpaywall_title.delete(" \t\r\n:,'\"").downcase
    distance = String::Similarity.levenshtein_distance(title1, title2)
    longer_string = [title1.length, title2.length].max
    similarity = (longer_string - distance) / longer_string.to_f
    return false unless similarity > 0.7
    true
  end
end
