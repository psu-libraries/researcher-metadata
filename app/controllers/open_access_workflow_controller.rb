class OpenAccessWorkflowController < UserController
  before_action :authenticate!
  before_action :raise_if_inaccessible

  layout 'manage_profile'

  private

  def publication
    @publication ||= current_user.publications.find(params[:id])
  end

  def raise_if_inaccessible
    if publication.has_open_access_information?
      raise ActiveRecord::RecordNotFound
    end
  end
end
