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
    file_version = nil
    extra_params = { journal: publication&.journal&.title, publication: publication }
    file_version_uploads = ScholarsphereFileVersionUploads.new(deposit_params.merge(extra_params))
    @job_ids ||= []

    if file_version_uploads.valid?
      @cache_files = file_version_uploads.cache_files
      exif_versions = file_version_uploads.exif_file_versions.compact
      file_version = ScholarsphereFileVersionUploads.version(exif_versions) if exif_versions.present?

      if file_version == I18n.t('file_versions.published_version')
        render partial: 'open_access_publications/file_version_result', locals: { file_version: file_version, cache_files: @cache_files }
      else
        @cache_files.each do |cache_file|
          file_version_job = ScholarspherePdfFileVersionJob.perform_later(file_meta: cache_file.to_json, publication_meta: version_check_pub_meta, exif_file_version: file_version)
          @job_ids.push(file_version_job.job_id)
        end

        render :scholarsphere_file_version
      end
    else
      flash.now[:alert] = "Validation failed:  #{file_version_uploads.errors.full_messages.join(', ')}"
      render :edit
    end
  rescue ActionController::ParameterMissing
    flash.now[:alert] = I18n.t('models.scholarsphere_work_deposit.validation_errors.file_upload_presence')
    @form = OpenAccessURLForm.new
    @authorship = Authorship.find_by(user: current_user, publication: publication)
    @deposit = ScholarsphereWorkDeposit.new_from_authorship(@authorship)
    @deposit.file_uploads.build
    render :edit
  end

  def file_version_result
    job_ids = params[:job_ids]
    pdf_file_versions = []
    exif_file_versions = []
    @cache_files = []
    @file_version = nil

    # Remove failed Delayed::Job and log an error
    job_ids&.reject! do |job_id|
      if Delayed::Job.exists?(job_id)
        job = Delayed::Job.find(job_id)
        if job.failed_at.nil?
          false
        else
          job.destroy
          Rails.logger.error "Job with ID #{job_id} failed and has been removed"
          true
        end
      else
        false
      end
    end

    job_ids&.each do |job_id|
      cached_data = Rails.cache.read("file_version_job_#{job_id}")
      if !cached_data.nil?
        pdf_file_versions << cached_data[:pdf_file_version]
        exif_file_versions << cached_data[:exif_file_version]
        @cache_files << JSON.parse(cached_data[:file_meta])
      end
    end

    if pdf_file_versions.compact.count == job_ids&.count
      file_versions = pdf_file_versions + exif_file_versions
      @file_version = ScholarsphereFileVersionUploads.version(file_versions)

      render partial: 'open_access_publications/file_version_result', locals: { file_version: @file_version, cache_files: @cache_files }
    else
      head :no_content
    end
  end

  def file_serve
    extension = File.extname(params[:filename])
    send_file(Rails.root + params[:filename],
              disposition: 'inline',
              type: Rack::Mime.mime_type(extension),
              x_sendfile: true)
  end

  def scholarsphere_deposit_form
    @cache_files = params.dig(:scholarsphere_work_deposit, :cache_files)
    if @cache_files.nil?
      flash.now[:alert] = I18n.t('models.scholarsphere_work_deposit.validation_errors.file_upload_presence')
      render :edit
    else
      @cache_files = params[:scholarsphere_work_deposit][:cache_files]
      @authorship = Authorship.find_by(user: current_user, publication: publication)
      @permissions = OabPermissionsService.new(@authorship.doi_url_path, params['scholarsphere_work_deposit']['file_version'])
      @deposit = ScholarsphereWorkDeposit.new_from_authorship(@authorship,
                                                              { rights: @permissions.licence,
                                                                embargoed_until: @permissions.embargo_end_date,
                                                                publisher_statement: @permissions.set_statement })

      @deposit.file_uploads.build
      render :scholarsphere_deposit_form
    end
  rescue StandardError
    flash[:error] = I18n.t('profile.open_access_publications.create_scholarsphere_deposit.fail')
  end

  def create_scholarsphere_deposit
    @authorship = Authorship.find_by(user: current_user, publication: publication)
    extra_params = { authorship: @authorship, deputy_user_id: current_user.deputy.id }
    @deposit = ScholarsphereWorkDeposit.new(deposit_params.merge(extra_params))
    @deposit.file_uploads = []

    files = params.dig(:scholarsphere_work_deposit, :file_uploads_attributes)
    files&.each do |_index, file|
      if file.present? && file[:cache_path].present?
        ss_file_upload = ScholarsphereFileUpload.new
        ss_file_upload.file = File.new(file[:cache_path])
        ss_file_upload.save!
        @deposit.file_uploads << ss_file_upload
      end
    end

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
                                                         :journal,
                                                         :job_ids,
                                                         cache_files: [:cache_path, :original_filename],
                                                         file_uploads_attributes: [:file, :file_cache])
    end

    def version_check_pub_meta
      {
        title: publication&.title,
        year: publication&.year,
        doi: publication&.doi,
        publisher: publication&.preferred_publisher_name
      }
    end
end
