# frozen_string_literal: true

class ActivityInsightOAFile < ApplicationRecord
  ALLOWED_VERSIONS = [
    I18n.t('file_versions.accepted_version'),
    I18n.t('file_versions.published_version'),
    'unknown'
  ].freeze

  def self.licenses
    ScholarsphereWorkDeposit.rights
  end

  def self.license_options
    ScholarsphereWorkDeposit.rights_options
  end

  belongs_to :publication,
             inverse_of: :activity_insight_oa_files

  belongs_to :user

  mount_uploader :file_download_location, ActivityInsightFileUploader

  scope :ready_for_download, -> {
    left_outer_joins(:publication)
      .where(publication: { publication_type: Publication.oa_publication_types })
      .left_outer_joins(publication: :open_access_locations)
      .where(open_access_locations: { publication_id: nil })
      .where(file_download_location: nil)
      .where(downloaded: nil)
      .where.not(location: nil)
      .where(%{(publication.open_access_status != 'gold' AND publication.open_access_status != 'hybrid') OR publication.open_access_status IS NULL})
  }

  scope :needs_permissions_check, -> {
    where(%{version = 'acceptedVersion' OR version = 'publishedVersion'})
      .where(permissions_last_checked_at: nil)
  }

  S3_AUTHORIZER_HOST_NAME = 'ai-s3-authorizer.k8s.libraries.psu.edu'

  validates :license, inclusion: { in: licenses, allow_blank: true }
  validates :version, inclusion: { in: ALLOWED_VERSIONS, allow_nil: true }

  delegate :doi_url_path, to: :publication, prefix: false
  delegate :doi, to: :publication, prefix: false

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

  def version_status_display
    return I18n.t('file_versions.published_version_display') if version == I18n.t('file_versions.published_version')

    return I18n.t('file_versions.accepted_version_display') if version == I18n.t('file_versions.accepted_version')

    'Unknown Version'
  end

  def download_location_value
    read_attribute(:file_download_location)
  end

  def journal
    publication.preferred_journal_title
  end

  rails_admin do
    show do
      group :publication_info do
        field(:publication)
        field(:doi)
        field(:journal)
      end

      group :file_info do
        field(:location)
        field(:version)
        field(:user)
        field(:created_at)
        field(:updated_at)
        field 'File download' do
          formatted_value do
            bindings[:view].link_to(bindings[:object].download_location_value.to_s, Rails.application.routes.url_helpers.activity_insight_oa_workflow_file_download_path(bindings[:object].id))
          end
        end
        field(:downloaded)
      end

      group :open_access_permissions do
        field(:permissions_last_checked_at)
        field(:license)
        field(:set_statement)
        field(:checked_for_set_statement)
        field(:embargo_date)
        field(:checked_for_embargo_date)
      end
    end

    list do
      field(:id)
      field(:publication)
      field(:downloaded)
      field(:version)
      field(:created_at)
      field(:updated_at)
      field(:permissions_last_checked_at)
      field(:user)
      field(:download_location_value) { label 'File download' }
      field(:location)
    end

    edit do
      group :publication_info do
        field(:publication) { read_only true }
        field(:doi) { read_only true }
        field(:journal) { read_only true }
      end

      group :file_info do
        field(:location) { read_only true }
        field 'File' do
          read_only true
          formatted_value do
            bindings[:view].link_to("Download #{bindings[:object].download_filename}", Rails.application.routes.url_helpers.activity_insight_oa_workflow_file_download_path(bindings[:object].id))
          end
        end
        field(:version, :enum) do
          required true
          enum do
            ActivityInsightOAFile::ALLOWED_VERSIONS.map { |v| [v, v] }
          end
        end
      end

      group :open_access_permissions do
        field(:license, :enum) do
          enum do
            ActivityInsightOAFile.license_options
          end
        end
        field(:set_statement)
        field(:checked_for_set_statement)
        field(:embargo_date)
        field(:checked_for_embargo_date)
      end
    end
  end
end
