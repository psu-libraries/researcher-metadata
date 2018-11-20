class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to main_app.root_path, alert: I18n.t('admin.authorization.not_authorized')
  end
end
