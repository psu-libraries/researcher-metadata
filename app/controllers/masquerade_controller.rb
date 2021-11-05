# frozen_string_literal: true

class MasqueradeController < UserController
  include MasqueradingBehaviors

  before_action :verify_deputies

  private

    def verify_deputies
      return if primary_user.deputies.include?(current_user)

      flash[:alert] = I18n.t('profile.errors.not_authorized')
      redirect_to root_path
    end
end
