class OrcidEmploymentsController < UserController
  before_action :authenticate!

  def create
    if current_user.orcid_access_token.present?
    else
      redirect_to "https://sandbox.orcid.org/oauth/authorize?client_id=#{Rails.configuration.x.orcid['client_id']}&response_type=code&scope=/activities/update&redirect_uri=#{URI::encode(orcid_access_tokens_url)}"
    end
  end
end
