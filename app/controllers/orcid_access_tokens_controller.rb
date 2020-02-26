class OrcidAccessTokensController < UserController
  before_action :authenticate!

  def new
    unless current_user.orcid_access_token.present?
      redirect_to "https://sandbox.orcid.org/oauth/authorize?client_id=#{Rails.configuration.x.orcid['client_id']}&response_type=code&scope=/activities/update&redirect_uri=#{URI::encode(orcid_access_token_url)}"
    end
  end

  def create
    client = OrcidOauthClient.new
    response = JSON.parse(client.create_token(params[:code]).to_s)
    current_user.update_attributes!(orcid_access_token: response['access_token'])

    redirect_to profile_bio_path
  end
end
