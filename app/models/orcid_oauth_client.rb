# frozen_string_literal: true

class OrcidOauthClient
  include HTTParty
  base_uri "https://#{'sandbox.' unless Rails.env.production?}orcid.org/oauth"

  def create_token(code)
    request = {
      headers: { 'Accept' => 'application/json' },
      body: {
        client_id: orcid_config['client_id'],
        client_secret: orcid_config['client_secret'],
        grant_type: 'authorization_code',
        code: code
      }
    }

    self.class.post('/token', request)
  end

  private

    def orcid_config
      Rails.configuration.x.orcid
    end
end
