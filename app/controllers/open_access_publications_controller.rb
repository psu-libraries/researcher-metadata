# frozen_string_literal: true

class OpenAccessPublicationsController < OpenAccessWorkflowController
  skip_before_action :redirect_if_inaccessible, only: [:edit]

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

  def scholarsphere_file_version
    @file_version = ExifFileVersion.new(params['scholarsphere_work_deposit']['file_uploads_attributes']['0']['file']).version
    render :scholarsphere_file_version
  end

  def scholarsphere_deposit_form
    @authorship = Authorship.find_by(user: current_user, publication: publication)
    @permissions = OabPermissionsService.new(@authorship.doi_url_path, params['scholarsphere_work_deposit']['file_version'])
    scholarsphere_deposit_flashes(@permissions)
    @deposit = ScholarsphereWorkDeposit.new_from_authorship(@authorship,
                                                            { rights: @permissions.licence,
                                                              embargoed_until: embargo_end_date_display(@permissions.embargo_end_date),
                                                              publisher_statement: @permissions.set_statement })
    @deposit.file_uploads.build
    render :scholarsphere_deposit_form
  end

  def create_scholarsphere_deposit
    @authorship = Authorship.find_by(user: current_user, publication: publication)
    extra_params = { authorship: @authorship, deputy_user_id: current_user.deputy.id }
    @deposit = ScholarsphereWorkDeposit.new(deposit_params.merge(extra_params))

    ActiveRecord::Base.transaction do
      @deposit.save!
      @authorship.update!(updated_by_owner_at: Time.current)
    end

    ScholarsphereUploadJob.perform_later(@deposit.id, current_user.id)

    flash[:notice] = I18n.t('profile.open_access_publications.create_scholarsphere_deposit.success')
    redirect_to edit_profile_publications_path
  rescue ActiveRecord::RecordInvalid
    @form = OpenAccessURLForm.new
    flash.now[:alert] = @deposit.errors.full_messages.join(', ')
    render :edit
  end

  helper_method :publication

  private

    def form_params
      params.require(:open_access_url_form).permit([:open_access_url])
    end

    def deposit_params
      params.require(:scholarsphere_work_deposit).permit(:title,
                                                         :description,
                                                         :publisher_statement,
                                                         :published_date,
                                                         :rights,
                                                         :embargoed_until,
                                                         :deposit_agreement,
                                                         :doi,
                                                         :subtitle,
                                                         :publisher,
                                                         :file_version,
                                                         file_uploads_attributes: [:file, :file_cache])
    end

    def scholarsphere_deposit_flashes(permissions)
      if permissions.permissions.present?
        flash[:info] = t('simple_form.scholarsphere_deposit_flashes.sharing_rules_found')
      else
        return flash[:info] = t('simple_form.scholarsphere_deposit_flashes.sharing_rules_not_found')
      end
      flash[:rights] = t('simple_form.hints.rights.oab_permission_found') if permissions.licence.present?
      flash[:publisher_statement] = t('simple_form.hints.publisher_statement.oab_permission_found') if permissions.set_statement.present?
      if permissions.embargo_end_date.present?
        flash[:embargoed_until] = if permissions.embargo_end_date < Date.today
                                    t('simple_form.hints.embargoed_until.oab_permission_found_expired')
                                  else
                                    t('simple_form.hints.embargoed_until.oab_permission_found')
                                  end
      end
    end

    def embargo_end_date_display(embargo_end_date)
      return embargo_end_date if embargo_end_date.present? && embargo_end_date > Date.today

      nil
    end
end
