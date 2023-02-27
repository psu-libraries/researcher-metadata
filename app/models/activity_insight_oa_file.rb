# frozen_string_literal: true

class ActivityInsightOAFile < ApplicationRecord
  belongs_to :publication,
             inverse_of: :activity_insight_oa_files

  scope :pub_without_permissions, -> { left_outer_joins(:publication).where(publication: { licence: nil }).where(publication: { doi_verified: true }) }
  scope :needs_permissions_check, -> { pub_without_permissions.where(version_checked: nil).where(%{version = ? OR version = ?}, I18n.t('file_versions.accepted_version'), I18n.t('file_versions.published_version')) }

  def version_status_display
    return 'Unknown Version' if version == 'unknown'

    'Wrong Version'
  end
end
