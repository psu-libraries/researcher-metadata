# frozen_string_literal: true

class ActivityInsightOaFile < ApplicationRecord
  belongs_to :publication,
             inverse_of: :activity_insight_oa_files

  scope :pub_without_permissions, -> { left_outer_joins(:publication).where(publication: { licence: nil }).where(publication: { doi_verified: true }) }
  scope :needs_permissions_check, -> { pub_without_permissions.where(version_checked: nil).where(%{version = 'acceptedVersion' OR version = 'publishedVersion'}) }
end
