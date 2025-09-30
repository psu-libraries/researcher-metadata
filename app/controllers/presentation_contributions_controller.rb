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
    current_user.presentation_contributions.update_all!(contribution_params)
  end

  private

    def contribution_params
      params.require(:presentation_contribution).permit(:visible_in_profile)
    end
end
