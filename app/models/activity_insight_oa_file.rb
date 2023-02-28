# frozen_string_literal: true

class ActivityInsightOAFile < ApplicationRecord
  belongs_to :publication,
             inverse_of: :activity_insight_oa_files
  
  mount_uploader :file, ActivityInsightFileUploader

  scope :pub_without_permissions, -> { left_outer_joins(:publication).where(publication: { licence: nil }).where(publication: { doi_verified: true }) }
  scope :needs_permissions_check, -> { pub_without_permissions.where(version_checked: nil).where(%{version = ? OR version = ?}, I18n.t('file_versions.accepted_version'), I18n.t('file_versions.published_version')) }
  scope :ready_for_download, -> { left_outer_joins(:publication)
    .where(publication: {publication_type: Publication.oa_publication_types})
    .where.not(publication: { licence: nil })
    .left_outer_joins(publication: :open_access_locations)
    .where(open_access_locations: { publication_id: nil })
    .where(file: nil)
    .where(downloaded: nil)
    .where.not(location: nil)
  }

  #activity_insight_oa_publication

    #with_no_oa_locations - distinct(:id).left_outer_joins(:open_access_locations).where(open_access_locations: { publication_id: nil })



  def stored_file_path
    file.file.file
  end
end
