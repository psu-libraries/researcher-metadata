# frozen_string_literal: true

class InternalPublicationWaiversController < OpenAccessWorkflowController
  def new
    authorship = current_user.authorships.find_by!(publication_id: params[:id])
    @waiver = InternalPublicationWaiver.new(authorship: authorship)
  end

  def create
    authorship = current_user.authorships.find_by!(publication_id: params[:id])
    waiver = InternalPublicationWaiver.new(waiver_params)
    waiver.authorship = authorship
    waiver.save!

    FacultyConfirmationsMailer.open_access_waiver_confirmation(UserProfile.new(current_user), waiver).deliver_now

    flash[:notice] = I18n.t('profile.internal_publication_waivers.create.success',
                            title: authorship.title)
    redirect_to edit_profile_publications_path
  end

  private

    def waiver_params
      params.require(:internal_publication_waiver).permit([:reason_for_waiver])
    end
end
