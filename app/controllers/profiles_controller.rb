class ProfilesController < ApplicationController
  layout 'profile'

  def show
    @profile = UserProfile.new(User.find_by!(webaccess_id: params[:webaccess_id]))
  end
end