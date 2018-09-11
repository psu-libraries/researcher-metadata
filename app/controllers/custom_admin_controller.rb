class CustomAdminController < ApplicationController
  before_action :authenticate_user!
  before_action :check_user_authorization

  private

  def check_user_authorization
    unless current_user.admin?
      flash[:alert] = I18n.t('admin.authorization.not_authorized')
      redirect_to main_app.root_path
    end
  end
end