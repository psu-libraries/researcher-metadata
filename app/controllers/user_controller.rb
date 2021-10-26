# frozen_string_literal: true

class UserController < ApplicationController
  private

    def authenticate!
      session[:requested_url] = request.url
      authenticate_user!
    end

    def current_user
      @current_user ||= CurrentUserBuilder.call(current_user: super, current_session: session)
    end
end
