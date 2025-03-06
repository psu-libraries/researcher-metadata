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

  def scholarsphere_file_version
    file_handler = ScholarsphereFileHandler.new(publication, deposit_params)
    @jobs ||= []
    @authorship = Authorship.find_by(user: current_user, publication: publication)
    @deposit = ScholarsphereWorkDeposit.new_from_authorship(@authorship)

    if file_handler.valid?
      @cache_files = file_handler.cache_files

      # If version is found with exif version check don't bother with the other check
      if file_handler.version.present?
        render :scholarsphere_file_version,
               locals: { file_version: file_handler.version,
                         cache_files: @cache_files.pluck(:cache_path) }
      else
        @cache_files.each do |cache_file|
          file_version_job = ScholarsphereVersionCheckJob.perform_later(file_path: cache_file[:cache_path].to_s,
                                                                        publication_id: publication.id)
          @jobs.push({ provider_id: file_version_job.provider_job_id, job_id: file_version_job.job_id })
        end

        render :scholarsphere_file_version, locals: { file_version: nil,
                                                      cache_files: @cache_files.pluck(:cache_path) }
      end
    else
      flash[:alert] = "Validation failed:  #{file_handler.errors.full_messages.join(', ')}"
      redirect_to edit_open_access_publication_path(publication)
    end
  rescue ActionController::ParameterMissing
    flash[:alert] = I18n.t('models.scholarsphere_work_deposit.validation_errors.file_upload_presence')
    redirect_to edit_open_access_publication_path(publication)
  end

  def file_version_result
    jobs = params[:jobs]
    pdf_file_versions = []
    cache_files = []

    # Remove failed Delayed::Job and log an error
    jobs&.reject! do |job|
      if Delayed::Job.exists?(job[:provider_id])
        job = Delayed::Job.find(job[:provider_id])
        if job.failed_at.nil?
          false
        else
          # Still need the file, so store file now
          cache_files << job.payload_object.job_data['arguments'].first['file_path']
          Rails.logger.error "Job with ID #{job[:provider_id]} failed"
          true
        end
      else
        false
      end
    end

    jobs&.each_with_index do |job, _index|
      cached_data = Rails.cache.read("file_version_job_#{job[:job_id]}")
      if !cached_data.nil?
        pdf_file_versions << [cached_data[:pdf_file_version], cached_data[:pdf_file_score]]
        cache_files << cached_data[:file_path]
      end
    end

    if pdf_file_versions.present? && pdf_file_versions.compact.count == jobs&.count
      # Determine best version by absolute score
      file_version = pdf_file_versions
        .select { |i| i.first if i.second.abs == pdf_file_versions.map { |n| n.second.abs }.max }
        .first
        .first

      render partial: 'open_access_publications/file_version_result', locals: { file_version: file_version,
                                                                                cache_files: cache_files }
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
      @permissions = OABPermissionsService.new(@authorship.doi_url_path, params['scholarsphere_work_deposit']['file_version'])
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
    extra_params = { authorship: @authorship,
                     deputy_user_id: current_user.deputy.id,
                     deposit_workflow: 'Standard OA Workflow' }
    @deposit = ScholarsphereWorkDeposit.new(deposit_params.merge(extra_params))
    @deposit.file_uploads = []

    files = params.dig(:scholarsphere_work_deposit, :file_uploads_attributes)
    files&.each_value do |file|
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
end
