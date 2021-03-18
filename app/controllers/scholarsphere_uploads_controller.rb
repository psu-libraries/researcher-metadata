class ScholarsphereUploadsController < OpenAccessWorkflowController
  def create
    authorship = Authorship.find_by(user: current_user, publication: publication)
    authorship.update!(authorship_params.merge(updated_by_owner_at: Time.current))
    redirect_to edit_profile_publications_path
  end

  private

  def authorship_params
    params.require(:authorship).permit(scholarsphere_file_uploads_attributes: [:file, :file_cache])
  end
end
