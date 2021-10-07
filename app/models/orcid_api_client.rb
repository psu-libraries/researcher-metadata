class OrcidAPIClient
  include HTTParty
  base_uri "https://api.#{'sandbox.' unless Rails.env.production?}orcid.org/v3.0"

  def initialize(resource)
    @resource = resource
  end

  def post
    request = {
      headers: {
        'Content-type' => 'application/vnd.orcid+json',
        'Authorization' => "Bearer #{resource.access_token}"
      },
      body: resource.to_json
    }

    self.class.post("/#{resource.orcid_id}/#{resource.orcid_type}", request)
  end

  private

    attr_reader :resource
end
