# frozen_string_literal: true

module Admin
  class MasqueradeController < RailsAdmin::ApplicationController
    def become
      session[:pretend_user_id] = pretender.id
      session[:admin_user_id] = current_user.id
      redirect_to main_app.profile_path(pretender.webaccess_id)
    end

    def unbecome
      session.delete(:pretend_user_id)
      session.delete(:admin_user_id)
      redirect_to main_app.profile_path(pretender.webaccess_id)
    end

    private

      def pretender
        @pretender ||= User.find(params[:user_id])
      end
  end
end
