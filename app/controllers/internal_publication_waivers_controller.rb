class InternalPublicationWaiversController < UserController
  before_action :authenticate_user!
  layout 'manage_profile'

  def new
    if publication.scholarsphere_upload_pending?
      raise ActiveRecord::RecordNotFound
    else
      authorship = current_user.authorships.find_by!(publication_id: params[:id])
      @waiver = InternalPublicationWaiver.new(authorship: authorship)
    end
  end

  def create
    if publication.scholarsphere_upload_pending?
      raise ActiveRecord::RecordNotFound
    else
      authorship = current_user.authorships.find_by!(publication_id: params[:id])
      waiver = InternalPublicationWaiver.new(waiver_params)
      waiver.authorship = authorship
      waiver.save!

      redirect_to edit_profile_publications_path
    end
  end

  private

  def publication
    @publication ||= current_user.publications
      .where(open_access_url: nil, user_submitted_open_access_url: nil)
      .find(params[:id])
  end

  def waiver_params
    params.require(:internal_publication_waiver).permit([:reason_for_waiver])
  end
end