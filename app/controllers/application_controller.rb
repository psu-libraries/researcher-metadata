# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_current_user
  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to main_app.root_path, alert: I18n.t('admin.authorization.not_authorized')
  end

  private

    def set_current_user
      Current.user = current_user
    end
end
