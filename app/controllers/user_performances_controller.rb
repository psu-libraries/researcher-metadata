class UserPerformancesController < ApplicationController
  before_action :authenticate_user!

  def update
    up = current_user.user_performances.find(params[:id])
    up.update_attributes!(up_params)
  end

  private

  def up_params
    params.require(:user_performance).permit(:visible_in_profile)
  end
end