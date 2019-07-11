class PresentationContributionsController < ApplicationController
  before_action :authenticate_user!

  def update
    contribution = current_user.presentation_contributions.find(params[:id])
    contribution.update_attributes!(contribution_params)
  end

  private

  def contribution_params
    params.require(:presentation_contribution).permit(:visible_in_profile)
  end
end