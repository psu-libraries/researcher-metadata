class AuthorshipsController < ApplicationController
  before_action :authenticate_user!

  def update
    authorship = current_user.authorships.find(params[:id])
    authorship.update_attributes!(authorship_params)
  end

  def sort
    authorships = current_user.authorships.find(params[:authorship])
    ActiveRecord::Base.transaction do
      authorships.each_with_index do |a, i|
        a.update_column(:position_in_profile, i + 1)
      end
    end
  end

  private

  def authorship_params
    params.require(:authorship).permit(:visible_in_profile)
  end
end