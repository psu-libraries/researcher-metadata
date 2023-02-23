# frozen_string_literal: true

class ActivityInsightOAWorkflowController < ApplicationController
  before_action :authenticate!
  before_action :require_admin

  def index; end

  private

    def authenticate!
      session[:requested_url] = request.url
      authenticate_user!
    end

    def require_admin
      unless current_user.admin?
        redirect_to root_path, alert: I18n.t('admin.authorization.not_authorized')
      end
    end
end
