# frozen_string_literal: true

class ExifUploads
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
      @exif_file_versions.push(ExifFileVersion.new(file_path: file.path, journal: journal))
      @file_uploads.push(file)
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

      {
        original_filename: file_upload.original_filename,
        cache_path: uploader.file.path
      }
    end
  end

  private

    def at_least_one_file_upload
      if @file_uploads.blank?
        flash[:error] = I18n.t('models.scholarsphere_work_deposit.validation_errors.file_upload_presence')
      end
    end
end
