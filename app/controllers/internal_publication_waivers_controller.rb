class InternalPublicationWaiversController < UserController
  before_action :authenticate_user!
  layout 'manage_profile'

  def new
    authorship = current_user.authorships.find_by!(publication_id: params[:id])
    @waiver = InternalPublicationWaiver.new(authorship: authorship)
  end
end