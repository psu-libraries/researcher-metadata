# frozen_string_literal: true

class ApplicationController < ActionController::Base
  byebug
  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to main_app.root_path, alert: I18n.t('admin.authorization.not_authorized')
  end
end
