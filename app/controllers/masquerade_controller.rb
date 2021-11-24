# frozen_string_literal: true

class MasqueradeController < UserController
  include MasqueradingBehaviors

  before_action :verify_deputies

  private

    def verify_deputies
      if current_user.masquerading?
        return if primary_user.available_deputy?(current_user.impersonator)
      else
        return if primary_user.available_deputy?(current_user)
      end

      flash[:alert] = I18n.t('profile.errors.not_authorized')
      redirect_to root_path
    end
end
