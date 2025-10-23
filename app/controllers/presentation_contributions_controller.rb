# frozen_string_literal: true

class PresentationContributionsController < UserController
  def update
    contribution = current_user.presentation_contributions.find(params[:id])
    contribution.update!(contribution_params)
  end

  def sort
    contributions = current_user.presentation_contributions.find(params[:presentation_contribution])
    ActiveRecord::Base.transaction do
      contributions.each_with_index do |c, i|
        c.update_column(:position_in_profile, i + 1)
      end
    end
  end

  def bulk_update_visibility
    visible = ActiveModel::Type::Boolean.new.cast(params[:visible_in_profile])
    UserProfile.new(current_user).presentation_records.each do |p|
      p.presentation_contributions.find_by(user: current_user).update(visible_in_profile: visible)
    end
  end

  private

    def contribution_params
      params.require(:presentation_contribution).permit(:visible_in_profile)
    end
end
