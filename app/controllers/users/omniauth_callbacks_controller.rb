# frozen_string_literal: true

# https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def azure_oauth
    @user = User.from_omniauth(request.env['omniauth.auth'])

    sign_in_and_redirect @user, event: :authentication
    set_flash_message(:notice, :success, kind: 'Penn State') if is_navigational_format?
  rescue User::OmniauthError
    if session['user_return_to'] == Rails.application.routes.url_helpers.new_external_publication_waiver_path ||
        session['user_return_to'] == Rails.application.routes.url_helpers.profile_bio_path
      redirect_to 'https://sites.psu.edu/openaccess/waiver-form/'
    else
      redirect_to root_path, alert: t('omniauth.user_not_found')
    end
  end

  def failure
    redirect_to root_path, alert: t('omniauth.login_error')
  end
end
