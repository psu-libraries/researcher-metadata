# frozen_string_literal: true

class UnpaywallClient
    attr_reader :publication

    def query_unpaywall(publication)
      if publication.doi.present?
        doi_url_path = Addressable::URI.encode(publication.doi_url_path)
        find_url = "https://api.unpaywall.org/v2/#{doi_url_path}?email=openaccess@psu.edu"
        json = JSON.parse(HttpService.get(find_url))
      else
        find_url = "https://api.unpaywall.org/v2/search/?query=#{CGI.escape(publication.title)}&email=openaccess@psu.edu"
        json = JSON.parse(HttpService.get(find_url))['results'].nil? ? '' : JSON.parse(HttpService.get(find_url))['results'].first['response']
      end

      UnpaywallResponse.new(json)
    end

end