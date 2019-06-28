class ProfilesController < ApplicationController
  layout 'profile'
  before_action :authenticate_user!, only: [:edit]

  def show
    @profile = UserProfile.new(User.find_by!(webaccess_id: params[:webaccess_id]))
  end

  def edit
    @profile = UserProfile.new(current_user)
  end

  helper_method :profile_for_current_user?

  private

  def profile_for_current_user?
    current_user && current_user.webaccess_id == params[:webaccess_id]
  end
end