# frozen_string_literal: true

class ScholarsphereClient
  def self.doi_query(publication)
    if publication.doi.present?
      doi_url_path = Addressable::URI.encode(publication.doi_url_path)
      find_url = "https://scholarsphere.psu.edu/api/v1/dois/#{doi_url_path}"
      response = HTTParty.get(find_url, headers: { 'X-API-KEY' => Settings.scholarsphere.client_key })
    else
      response = ''
    end

    ScholarsphereResponse.new(response)
  end
end
