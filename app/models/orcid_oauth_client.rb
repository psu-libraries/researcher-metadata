class OrcidOauthClient
  include HTTParty
  base_uri "https://sandbox.orcid.org/oauth"

  def create_token(code)
    request = {
      headers: {"Accept" => "application/json"},
      body: {
        client_id: Rails.configuration.x.orcid['client_id'],
        client_secret: Rails.configuration.x.orcid['client_secret'],
        grant_type: 'authorization_code',
        code: params['code']
      }
    }

    self.class.post("/token", request)
  end
end
