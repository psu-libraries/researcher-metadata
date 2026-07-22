# frozen_string_literal: true

class OpenAccessPublicationsController < OpenAccessWorkflowController
  skip_before_action :redirect_if_inaccessible, only: [:edit, :activity_insight_file_download]

  def edit
    if publication.no_open_access_information?
      @form = OpenAccessURLForm.new
      @authorship = Authorship.find_by(user: current_user, publication: publication)
      @deposit = ScholarsphereWorkDeposit.new_from_authorship(@authorship)
      @deposit.file_uploads.build
      render :edit
    else
      render :readonly_edit
    end
  end

  def update
    @form = OpenAccessURLForm.new(form_params)

    if @form.valid?
      oal = publication.open_access_locations.find_or_initialize_by(source: Source::USER)
      oal.url = @form.open_access_url
      oal.deputy_user_id = current_user.deputy.id
      oal.save!

      flash[:notice] = I18n.t('profile.open_access_publications.update.success')
      redirect_to edit_profile_publications_path
    else
      flash[:alert] = "Validation failed:  #{@form.errors.full_messages.join(', ')}"
      @authorship = Authorship.find_by(user: current_user, publication: publication)
      @deposit = ScholarsphereWorkDeposit.new(authorship: @authorship)
      @deposit.file_uploads.build
      render 'edit'
    end
  end

  def activity_insight_file_download
    file = ActivityInsightOAFile.find(publication.activity_insight_oa_files.first.id)
    send_file(file.stored_file_path)
  end

  def create_scholarsphere_deposit
    @authorship = Authorship.find_by(user: current_user, publication: publication)
    @deposit = ScholarsphereWorkDeposit.new_from_authorship(@authorship)
    @deposit.deposit_workflow = 'Standard OA Workflow'
    @deposit.deputy_user_id = current_user.deputy.id
    ActiveRecord::Base.transaction do
      @deposit.save!
      @authorship.update!(updated_by_owner_at: Time.current)
    end
    service = ScholarsphereDepositService.new(@deposit, current_user.deputy.presence || current_user)
    edit_url = service.create_draft
    redirect_to edit_url, allow_other_host: true
  rescue ActiveRecord::RecordInvalid => e
    @deposit.record_failure(e.to_s)
    @form = OpenAccessURLForm.new
    flash.now[:alert] = @deposit.errors.full_messages.join(', ')
    render :edit
  rescue ScholarsphereDepositService::DepositFailed => e
    @deposit.record_failure(e.to_s)
    @form = OpenAccessURLForm.new
    flash[:alert] = I18n.t('profile.open_access_publications.create_scholarsphere_deposit.fail')
    render :edit
  end

  helper_method :publication

  private

    def form_params
      params.require(:open_access_url_form).permit([:open_access_url])
    end
end
