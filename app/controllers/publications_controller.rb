# frozen_string_literal: true

class PublicationsController < ProfileManagementController
  def index
    if params[:search] && params[:search][:title].present?
      @publications = base_publication_query
        .where('title ILIKE ?', "%#{params[:search][:title]}%")
        .limit(100).order(:title)
    end
  end

  def show
    @publication = base_publication_query.find(params[:id])
  end

  private

    def base_publication_query
      Publication
        .visible
        .where.not(id: current_user.authorships.map { |a| a.publication.id })
    end

    def resolve_layout
      'manage_profile'
    end
end
