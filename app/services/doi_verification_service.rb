# frozen_string_literal: true
require 'string/similarity'

class DoiVerificationService
  attr_reader :publication
  
  def initialize(publication)
    @publication = publication
  end

  def verify
    pub_title = publication.title + publication.secondary_title.to_s
    unpaywall_title = getUnpaywallData(publication.doi)
    publication.doi_verified = compareTitle(pub_title, unpaywall_title)
    publication.save!
  end

  private

  def getUnpaywallData(doi)
    doi_url_path = Addressable::URI.encode(publication.doi_url_path)
    find_url = "https://api.unpaywall.org/v2/#{doi_url_path}?email=openaccess@psu.edu"
    json = JSON.parse(HttpService.get(find_url))
    json['title']
  end

  def compareTitle(pub_title, unpaywall_title)
    title1 = pub_title.delete(" \t\r\n:,'\"").downcase
    title2 = unpaywall_title.delete(" \t\r\n:,'\"").downcase
    byebug
    result = String::Similarity.levenshtein(title1, title2)
    return false unless result > 0.7
    true
  end
end
  