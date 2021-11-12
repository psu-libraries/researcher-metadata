# frozen_string_literal: true

class PublicationsController < ProfileManagementController
  def index
    publications = Publication.claimable_by(current_user)
    if params[:search] && (title_search? || name_search?)
      if title_search?
        publications = publications
          .where('title ILIKE ?', "%#{params[:search][:title]}%")
      end
      if name_search?
        publications = publications
          .joins(:contributor_names)
          .where('contributor_names.first_name ILIKE ?', "%#{params[:search][:first_name]}%")
          .where('contributor_names.last_name ILIKE ?', "%#{params[:search][:last_name]}%")
      end
    else
      publications = Publication.none
    end
    @publications = publications.limit(1000).order(:title)
  end

  def show
    @publication = Publication.claimable_by(current_user).find(params[:id])
  end

  private

    def resolve_layout
      'manage_profile'
    end

    def title_search?
      params[:search][:title].present?
    end

    def name_search?
      params[:search][:first_name].present? && params[:search][:last_name].present?
    end
end
