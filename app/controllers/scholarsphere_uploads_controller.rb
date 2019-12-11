class ScholarsphereUploadsController < OpenAccessWorkflowController
  def create
    authorship = Authorship.find_by(user: current_user, publication: publication)
    authorship.update_attributes!(scholarsphere_uploaded_at: Time.current)
    redirect_to 'https://scholarsphere.psu.edu/concern/generic_works/new'
  end
end
