class OrcidAccessTokensController < UserController
  before_action :authenticate!

  def new
    unless current_user.orcid_access_token.present?
      redirect_to "https://sandbox.orcid.org/oauth/authorize?client_id=#{Rails.configuration.x.orcid['client_id']}&response_type=code&scope=/activities/update&redirect_uri=#{URI::encode(orcid_access_token_url)}"
    end
  end

  def create
    request = {
      headers: {"Accept" => "application/json"},
      body: {
        client_id: Rails.configuration.x.orcid['client_id'],
        client_secret: Rails.configuration.x.orcid['client_secret'],
        grant_type: 'authorization_code',
        code: params['code'],
        redirect_uri: profile_bio_url
      }
    }

    response = HTTParty.post("https://sandbox.orcid.org/oauth/token", request)

    raise response.inspect
  end
end
