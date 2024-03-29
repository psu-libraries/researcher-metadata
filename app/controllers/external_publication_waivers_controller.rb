# frozen_string_literal: true

class ExternalPublicationWaiversController < ProfileManagementController
  def new
    @waiver = current_user.external_publication_waivers.build
  end

  def create
    @waiver = current_user
      .external_publication_waivers
      .build(waiver_params.merge(deputy_user_id: current_user.deputy.id))
    @waiver.save!
    flash[:notice] = I18n.t('profile.external_publication_waivers.create.success')
    FacultyConfirmationsMailer.open_access_waiver_confirmation(UserProfile.new(current_user), @waiver).deliver_now
    redirect_to edit_profile_publications_path
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = e
    render :new
  end

  private

    def waiver_params
      params.require(:waiver).permit([:publication_title,
                                      :journal_title,
                                      :reason_for_waiver,
                                      :abstract,
                                      :doi,
                                      :publisher])
    end
end
