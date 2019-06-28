class User::SessionsController < ApplicationController
  include Devise::Behaviors::HttpHeaderAuthenticatableBehavior
  skip_before_action :authenticate_user!, raise: false

  def new
    redirect_to sign_in_url
  end

  def destroy
    cookies.delete(request.env['COSIGN_SERVICE']) if request.env['COSIGN_SERVICE']
    session.clear
    redirect_to sign_out_url
  end

  private

  def sign_in_url(after_sign_in_url=request.url)
    "https://webaccess.psu.edu/?cosign-#{request.host}&#{after_sign_in_url}"
  end

  def sign_out_url(after_sign_out_url=root_url)
    "https://webaccess.psu.edu/cgi-bin/logout?#{after_sign_out_url}?message=signed_out"
  end
end