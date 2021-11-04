# frozen_string_literal: true

class PublicationsController < ProfileManagementController
  def index
    if params[:search] && params[:search][:title].present?
      @publications = Publication
        .visible
        .where.not(id: current_user.authorships.map { |a| a.publication.id })
        .where('title ILIKE ?', "%#{params[:search][:title]}%")
        .limit(100)
    end
  end
end
