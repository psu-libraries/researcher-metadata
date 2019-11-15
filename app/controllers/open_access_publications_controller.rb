class OpenAccessPublicationsController < UserController
  before_action :authenticate!
  layout 'manage_profile'

  def edit
    @publication = find_publication
  end

  def update
    publication = find_publication
    publication.update_attributes!(publication_params)
    flash[:notice] = I18n.t('profile.open_access_publications.update.success')
    redirect_to edit_profile_publications_path
  end

  private

  def publication_params
    params.require(:publication).permit([:user_submitted_open_access_url])
  end

  def find_publication
    current_user.publications
      .where(open_access_url: nil,
             user_submitted_open_access_url: nil)
      .find(params[:id])
  end
end
