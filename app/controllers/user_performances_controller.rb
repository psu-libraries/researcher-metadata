# frozen_string_literal: true

class UserPerformancesController < UserController
  def update
    up = current_user.user_performances.find(params[:id])
    up.update!(up_params)
  end

  def sort
    ups = current_user.user_performances.find(params[:user_performance])
    ActiveRecord::Base.transaction do
      ups.each_with_index do |p, i|
        p.update_column(:position_in_profile, i + 1)
      end
    end
  end

  private

    def up_params
      params.require(:user_performance).permit(:visible_in_profile)
    end
end
