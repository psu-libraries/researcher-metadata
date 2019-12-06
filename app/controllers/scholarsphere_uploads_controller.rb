class ScholarsphereUploadsController < UserController
  before_action :authenticate!

  def create
    publication = current_user.publications
      .where(open_access_url: nil, user_submitted_open_access_url: nil)
      .find(params[:id])

    if publication.scholarsphere_upload_pending?
      raise ActiveRecord::RecordNotFound
    else
      authorship = Authorship.find_by(user: current_user, publication: publication)
      authorship.update_attributes!(scholarsphere_uploaded_at: Time.current)
      redirect_to 'https://scholarsphere.psu.edu/concern/generic_works/new'
    end
  end
end
