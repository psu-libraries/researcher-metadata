# frozen_string_literal: true

module MasqueradingBehaviors
  extend ActiveSupport::Concerns

  SESSION_ID = :primary_user_id

  def become
    session[SESSION_ID] = primary_user.id
    redirect_to main_app.profile_path(primary_user.webaccess_id)
  end

  def unbecome
    session.delete(SESSION_ID)
    redirect_to main_app.profile_path(primary_user.webaccess_id)
  end

  private

    def primary_user
      @primary_user ||= User.find(params[:user_id])
    end
end
