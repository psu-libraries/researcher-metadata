class ProfilesController < ApplicationController
  layout :resolve_layout

  before_action :authenticate!, except: [:show]

  def show
    @profile = UserProfile.new(User.find_by!(webaccess_id: params[:webaccess_id]))
  end

  def edit_publications
    authorships = UserProfile.new(current_user).publication_records.uniq.
      map { |p| p.authorships.find_by(user: current_user) }
    @authorships = authorships.map { |a| AuthorshipDecorator.new(a) }
  end

  def edit_presentations
    @presentation_contributions = UserProfile.new(current_user).presentation_records.uniq.
      map { |p| p.presentation_contributions.find_by(user: current_user) }
  end

  def edit_performances
    @user_performances = UserProfile.new(current_user).performance_records.uniq.
      map { |p| p.user_performances.find_by(user: current_user) }
  end

  helper_method :profile_for_current_user?

  private

  def profile_for_current_user?
    current_user && current_user.webaccess_id == params[:webaccess_id]
  end

  def authenticate!
    session[:requested_url] = request.url
    authenticate_user!
  end

  def resolve_layout
    if action_name == 'show'
      'profile'
    else
      'manage_profile'
    end
  end
end