# frozen_string_literal: true

class ActivityInsightOAFile < ApplicationRecord
  belongs_to :publication,
             inverse_of: :activity_insight_oa_files

  mount_uploader :file_download_location, ActivityInsightFileUploader

  scope :ready_for_download, -> {
    left_outer_joins(:publication)
      .where(publication: { publication_type: Publication.oa_publication_types })
      .where.not(publication: { licence: nil })
      .left_outer_joins(publication: :open_access_locations)
      .where(open_access_locations: { publication_id: nil })
      .where(file_download_location: nil)
      .where(downloaded: nil)
      .where.not(location: nil)
  }

  S3_AUTHORIZER_HOST_NAME = 'ai-s3-authorizer.k8s.libraries.psu.edu'

  def stored_file_path
    file_download_location.file&.file
  end

  def download_filename
    location.split('/').last
  end

  def update_download_location
    update_column(:file_download_location, download_filename)
  end

  def download_uri
    "https://#{S3_AUTHORIZER_HOST_NAME}/api/v1/#{URI::DEFAULT_PARSER.escape(location)}"
  end

  ALLOWED_VERSIONS = [I18n.t('file_versions.accepted_version'),
                      I18n.t('file_versions.published_version'),
                      'unknown'].freeze

  validates :version, inclusion: { in: ALLOWED_VERSIONS, allow_nil: true }

  def version_status_display
    return  I18n.t('file_versions.published_version_display') if version == I18n.t('file_versions.published_version')

    return I18n.t('file_versions.accepted_version_display') if version == I18n.t('file_versions.accepted_version')
   
    'Unknown Version'
  end

  rails_admin do
    show do
      field(:location)
      field(:version)
      field(:created_at)
      field(:updated_at)
      field(:publication)
    end

    list do
      field(:id)
      field(:location)
      field(:version)
      field(:created_at)
      field(:updated_at)
      field(:publication)
    end

    edit do
      field(:location) { read_only true }
      field(:version, :enum) do
        required true
        enum do
          ActivityInsightOAFile::ALLOWED_VERSIONS.map { |v| [v, v] }
        end
      end
    end
  end
end
