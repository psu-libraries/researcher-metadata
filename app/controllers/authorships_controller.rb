# frozen_string_literal: true

class AuthorshipsController < UserController
  def create
    publication = Publication.find(authorship_create_params[:publication_id])
    current_user.claim_publication(
      publication,
      authorship_create_params[:author_number]
    )

    flash[:notice] = I18n.t('profile.authorships.create.success', title: publication.title)
    redirect_to edit_profile_publications_path
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = e.message
    redirect_to publication_path(authorship_create_params[:publication_id])
  end

  def update
    authorship = current_user.authorships.find(params[:id])
    authorship.update!(authorship_update_params.merge(updated_by_owner_at: Time.current))
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

    def authorship_create_params
      params.require(:authorship).permit([:publication_id, :author_number])
    end

    def authorship_update_params
      params.require(:authorship).permit(:visible_in_profile)
    end
end
