class OpenAccessWorkflowController < UserController
  before_action :authenticate!
  before_action :raise_if_inaccessible

  layout 'manage_profile'

  private

  def publication
    @publication ||= current_user.publications
      .where(%{(open_access_url IS NULL OR open_access_url = '') AND (user_submitted_open_access_url IS NULL OR user_submitted_open_access_url = '')})
      .find(params[:id])
  end

  def raise_if_inaccessible
    if publication.scholarsphere_upload_pending? || publication.open_access_waived?
      raise ActiveRecord::RecordNotFound
    end
  end
end
