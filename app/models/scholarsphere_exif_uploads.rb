# frozen_string_literal: true

class ScholarsphereExifUploads
  include ActiveModel::Model

  attr_accessor :journal

  validate :at_least_one_file_upload

  def initialize(attributes = {})
    @journal = attributes[:journal]

    super
  end

  def file_uploads_attributes=(attributes)
    @exif_file_versions ||= []
    @file_uploads ||= []

    attributes.each do |_i, file_upload_params|
      file = file_upload_params[:file]
      unless file.nil?
        @exif_file_versions.push(ScholarsphereExifFileVersion.new(file_path: file.path, journal: journal))
        @file_uploads.push(file)
      end
    end
  end

  def version
    @exif_file_versions.map do |exif|
      return exif.version if exif.accepted_version?

      # Either Published Version or nil
      exif.version
    end.compact.uniq.first
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
        flash[:error] = I18n.t('models.scholarsphere_work_deposit.validation_errors.file_upload_presence')
      end
    end
end
