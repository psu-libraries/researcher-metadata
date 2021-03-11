class OpenAccessWorkflowController < UserController
  before_action :authenticate!
  before_action :redirect_if_inaccessible

  layout 'manage_profile'

  private

  def publication
    @publication ||= current_user.publications.journal_article.find(params[:id])
  end

  def redirect_if_inaccessible
    if publication.has_open_access_information?
      redirect_to edit_open_access_publication_path(publication)
    end
  end
end
