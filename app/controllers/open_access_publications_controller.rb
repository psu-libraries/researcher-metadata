class OpenAccessPublicationsController < UserController
  before_action :authenticate!
  before_action :raise_if_inaccessible
  layout 'manage_profile'

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
      render 'edit'
    end
  end

  private

  def form_params
    params.require(:open_access_url_form).permit([:open_access_url])
  end

  def publication
    @publication ||= current_user.publications
      .where(open_access_url: nil,
             user_submitted_open_access_url: nil)
      .find(params[:id])
  end

  def raise_if_inaccessible
    if publication.scholarsphere_upload_pending?
      raise ActiveRecord::RecordNotFound
    end
  end
end
