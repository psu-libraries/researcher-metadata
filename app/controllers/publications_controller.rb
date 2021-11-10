# frozen_string_literal: true

class PublicationsController < ProfileManagementController
  def index
    if params[:search] && params[:search][:title].present?
      @publications = Publication.claimable_by(current_user)
        .where('title ILIKE ?', "%#{params[:search][:title]}%")
        .limit(1000).order(:title)
    end
  end

  def show
    @publication = Publication.claimable_by(current_user).find(params[:id])
  end

  private

    def resolve_layout
      'manage_profile'
    end
end
