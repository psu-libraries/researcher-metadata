# frozen_string_literal: true

class UnpaywallClient
  def self.query_unpaywall(publication)
    if publication.doi.present?
      doi_url_path = Addressable::URI.encode(publication.doi_url_path)
      find_url = "https://api.unpaywall.org/v2/#{doi_url_path}?email=openaccess@psu.edu"
      json = JSON.parse(HttpService.get(find_url))
    elsif publication.publication_type != 'Extension Publication'
      find_url = "https://api.unpaywall.org/v2/search/?query=#{CGI.escape(publication.title)}&email=openaccess@psu.edu"
      json = JSON.parse(HttpService.get(find_url))['results'].blank? ? '' : JSON.parse(HttpService.get(find_url))['results'].first['response']
    else
      json = {}
    end

    UnpaywallResponse.new(json)
  end
end
