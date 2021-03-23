class OpenAccessPublicationsController < OpenAccessWorkflowController
  skip_before_action :redirect_if_inaccessible, only: [:edit]
  
  def edit
    if publication.no_open_access_information?
      @form = OpenAccessURLForm.new
      @authorship = Authorship.find_by(user: current_user, publication: publication)
      @deposit = ScholarsphereWorkDeposit.new(authorship: @authorship)
      @deposit.file_uploads.build
      render :edit
    else
      render :readonly_edit
    end
  end

  def update
    @form = OpenAccessURLForm.new(form_params)
      
    if @form.valid?
      publication.update_attributes!(user_submitted_open_access_url: @form.open_access_url)
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

  def create_scholarsphere_deposit
    @authorship = Authorship.find_by(user: current_user, publication: publication)
    ActiveRecord::Base.transaction do
      @deposit = ScholarsphereWorkDeposit.create!(authorship: @authorship)
      @deposit.update!(deposit_params)
      @authorship.update!(updated_by_owner_at: Time.current)
    end

    service = ScholarsphereDepositService.new(@deposit.reload, current_user)
    service.create

    redirect_to edit_profile_publications_path
  rescue ActiveRecord::RecordInvalid
    @form = OpenAccessURLForm.new
    flash.now[:alert] = @deposit.errors.full_messages.join(" ")
    render :edit
  end

  helper_method :publication

  private

  def form_params
    params.require(:open_access_url_form).permit([:open_access_url])
  end

  def deposit_params
    params.require(:scholarsphere_work_deposit).permit(file_uploads_attributes: [:file, :file_cache])
  end
end
