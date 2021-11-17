# frozen_string_literal: true

class PublicationsController < ProfileManagementController
  def index
    publications = Publication.claimable_by(current_user)
    if search_present?
      if title_search_present?
        publications = publications
          .where('title ILIKE ?', "%#{title_param}%")
      end
      if name_search_present?
        publications = publications
          .joins(:contributor_names)
          .where('contributor_names.first_name ILIKE ?', "%#{first_name_param}%")
          .where('contributor_names.last_name ILIKE ?', "%#{last_name_param}%")
      end
    else
      publications = Publication.none
    end
    @publications = publications.limit(1000).order(:title)
  end

  def show
    @publication = Publication.claimable_by(current_user).find(params[:id])
  end

  helper_method :search_present?, :search_incomplete?, :search_term

  private

    def resolve_layout
      'manage_profile'
    end

    def title_param
      params[:search][:title]
    end

    def first_name_param
      params[:search][:first_name]
    end

    def last_name_param
      params[:search][:last_name]
    end

    def title_search_present?
      title_param.present?
    end

    def name_search_present?
      first_name_param.present? && last_name_param.present?
    end

    def search_present?
      params[:search] && (title_search_present? || name_search_present?)
    end

    def search_incomplete?
      params[:search] && !(title_search_present? || name_search_present?)
    end

    def search_term
      term = ''
      term += %{title:  "#{title_param}"} if title_search_present?
      term += ' and ' if title_search_present? && name_search_present?
      term += %{author name:  "#{first_name_param} #{last_name_param}"} if name_search_present?
      term
    end
end
