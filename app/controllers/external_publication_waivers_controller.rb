class ExternalPublicationWaiversController < ProfileManagementController
  before_action :authenticate!

  def new
    @waiver = current_user.external_publication_waivers.build
  end

  def create
    @waiver = current_user.external_publication_waivers.build(waiver_params)
    @waiver.save!
    flash[:notice] = I18n.t('profile.external_publication_waivers.create.success')
    redirect_to edit_profile_publications_path
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = e
    render :new
  end

  private

  def waiver_params
    params.require(:external_publication_waiver).permit([:publication_title,
                                                         :journal_title,
                                                         :reason_for_waiver,
                                                         :abstract,
                                                         :doi,
                                                         :publisher])
  end
end
