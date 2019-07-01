class AuthorshipsController < ApplicationController
  before_action :authenticate_user!

  def update
    authorship = current_user.authorships.find(params[:id])
    authorship.update_attributes!(authorship_params)
  end

  def sort

  end

  private

  def authorship_params
    params.require(:authorship).permit(:visible_in_profile)
  end
end