# frozen_string_literal: true

class UserController < ApplicationController
  before_action :authenticate!

  private

    def authenticate!
      session[:requested_url] = request.url
      authenticate_user!
    end

    def current_user
      @current_user ||= super

      CurrentUserBuilder.call(current_user: @current_user, current_session: session)
    end
end
