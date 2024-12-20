# frozen_string_literal: true

class ScholarsphereFileHandler
  # This class is designed to handle the initial upload of files
  # to RMD for version checking in the ScholarSphere upload workflow.
  # It validates that files have been uploaded and caches the files
  # for us so they can be accessed later in the ScholarSphere
  # upload process. It also determines the version of the file
  # via the exif file metadata check.
  include ActiveModel::Model

  attr_accessor :publication, :exif_file_versions

  validate :at_least_one_file_upload

  def initialize(publication, attributes = {})
    @publication = publication

    super(attributes)
  end

  def file_uploads_attributes=(attributes)
    @exif_file_versions ||= []
    @file_uploads ||= []

    attributes.each_value do |file_upload_params|
      file = file_upload_params[:file]
      if file.present?
        exif_file_version = ExifFileVersionChecker.new(file_path: file.path,
                                                       journal: publication&.journal&.title).version
        @exif_file_versions.push(exif_file_version)
        @file_uploads.push(file)
      end
    end
  end

  def version
    # Select 'Accepted Version' if present since this check is most strict
    return I18n.t('file_versions.accepted_version') if exif_file_versions.include? I18n.t('file_versions.accepted_version')

    # Otherwise take 'Published Version'
    return I18n.t('file_versions.published_version') if exif_file_versions.include? I18n.t('file_versions.published_version')

    # Either 'unknown' or nil
    exif_file_versions.compact.uniq.first
  end

  def cache_files
    uploader = ScholarsphereFileUploader.new

    @file_uploads.map do |file_upload|
      uploader.cache!(file_upload)
      cached_file_info(file_upload, uploader)
    end
  end

  private

    def cached_file_info(file_upload, uploader)
      cache_dir = uploader.cache_dir.relative_path_from(Rails.root)

      {
        original_filename: file_upload.original_filename,
        cache_path: cache_dir + uploader.cache_name
      }
    end

    def at_least_one_file_upload
      if @file_uploads.blank?
        errors.add(:file_uploads, I18n.t('models.scholarsphere_work_deposit.validation_errors.file_upload_presence'))
      end
    end
end
