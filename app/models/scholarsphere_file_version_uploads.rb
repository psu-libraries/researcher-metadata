# frozen_string_literal: true

class ScholarsphereFileVersionUploads
  include ActiveModel::Model

  attr_accessor :journal, :publication

  validate :at_least_one_file_upload

  def initialize(attributes = {})
    @journal = attributes[:journal]
    @publication = attributes[:publication]

    super
  end

  def file_uploads_attributes=(attributes)
    @exif_file_versions ||= []
    @pdf_file_versions ||= []
    @file_uploads ||= []

    attributes.each do |_i, file_upload_params|
      file = file_upload_params[:file]
      if file.present?
        @exif_file_versions.push(ScholarsphereExifFileVersion.new(file_path: file.path, journal: journal))
        
        if @exif_file_versions.empty?
          @pdf_file_versions.push(ScholarspherePdfFileVersion.new(file_path: file.path,
                                                                  filename: file.original_filename,
                                                                  publication: publication))
        end

        @file_uploads.push(file)
      end
    end
  end

  def version
    all_file_versions = @exif_file_versions + @pdf_file_versions

    all_file_versions.map do |file_version|
      return file_version.version if file_version.version == I18n.t('file_versions.accepted_version')

      # Either Published Version or nil
      file_version.version
    end.compact.uniq.first
  end

  def version_display
    if version == I18n.t('file_versions.accepted_version')
      I18n.t('file_versions.accepted_version_display')
    elsif version == I18n.t('file_versions.published_version')
      I18n.t('file_versions.published_version_display')
    end
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
