class OpenAccessPublicationsController < OpenAccessWorkflowController
  def edit
    @form = OpenAccessURLForm.new
  end

  def update
    @form = OpenAccessURLForm.new(form_params)
      
    if @form.valid?
      @publication.update_attributes!(user_submitted_open_access_url: @form.open_access_url)
      flash[:notice] = I18n.t('profile.open_access_publications.update.success')
      redirect_to edit_profile_publications_path
    else
      flash[:alert] = "Validation failed:  #{@form.errors.full_messages.join(', ')}"
      render 'edit'
    end
  end

  private

  def form_params
    params.require(:open_access_url_form).permit([:open_access_url])
  end
end
