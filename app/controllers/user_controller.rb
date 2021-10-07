class UserController < ApplicationController
  private

    def authenticate!
      session[:requested_url] = request.url
      authenticate_user!
    end
end
