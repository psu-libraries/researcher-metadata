class ScholarsphereUploadsController < UserController
  before_action :authenticate!

  def create
    publication = current_user.publications
      .where(open_access_url: nil, user_submitted_open_access_url: nil)
      .find(params[:id])
    redirect_to 'https://scholarsphere.psu.edu/concern/generic_works/new'
  end
end
