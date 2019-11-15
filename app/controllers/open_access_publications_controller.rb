class OpenAccessPublicationsController < UserController
  before_action :authenticate!
  layout 'manage_profile'

  def edit
    #TODO: add second open_access_url attribute to this query once it has been created
    @publication = current_user.publications.where(open_access_url: nil).find(params[:id])
  end
end
