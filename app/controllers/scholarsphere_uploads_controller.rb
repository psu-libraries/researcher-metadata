class ScholarsphereUploadsController < OpenAccessWorkflowController
  def create
    authorship = Authorship.find_by(user: current_user, publication: publication)
    authorship.update!(scholarsphere_uploaded_at: Time.current,
                       updated_by_owner_at: Time.current)
    redirect_to 'https://scholarsphere.psu.edu/dashboard/form/work_versions/new'
  end
end
