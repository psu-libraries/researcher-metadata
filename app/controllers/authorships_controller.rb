class AuthorshipsController < ApplicationController
  before_action :authenticate_user!

  def update
    authorship = current_user.authorships.find(params[:id])
    authorship.update!(authorship_params.merge(updated_by_owner_at: Time.current))
  end

  def sort
    authorships = current_user.authorships.find(params[:authorship_row])
    ActiveRecord::Base.transaction do
      authorships.each_with_index do |a, i|
        a.update_column(:position_in_profile, i + 1)
        a.update_column(:updated_by_owner_at, Time.current)
      end
    end
  end

  private

    def authorship_params
      params.require(:authorship).permit(:visible_in_profile)
    end
end
