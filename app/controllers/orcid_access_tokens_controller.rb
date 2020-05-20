class OrcidAccessTokensController < UserController
  before_action :authenticate!

  def new
    if current_user.orcid_access_token.present?
      flash[:notice] = I18n.t('profile.orcid_access_tokens.new.already_linked')
      redirect_to profile_bio_path
    else
      redirect_to "https://sandbox.orcid.org/oauth/authorize?client_id=#{Rails.configuration.x.orcid['client_id']}&response_type=code&scope=/activities/update&redirect_uri=#{URI::encode(orcid_access_token_url)}"
    end
  end

  def create
    response = oauth_client.create_token(params[:code])

    if response.code == 200
      response_body = JSON.parse(response.to_s)
      current_user.update_attributes!(orcid_access_token: response['access_token'])
      flash[:notice] = I18n.t('profile.orcid_access_tokens.create.success')
    else
      flash[:alert] = I18n.t('profile.orcid_access_tokens.create.error')
    end

    redirect_to profile_bio_path
  end

  private

  def oauth_client
    @oauth_client ||= OrcidOauthClient.new
  end
end
