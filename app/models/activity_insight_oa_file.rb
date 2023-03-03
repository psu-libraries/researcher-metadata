# frozen_string_literal: true

class ActivityInsightOAFile < ApplicationRecord
  belongs_to :publication,
             inverse_of: :activity_insight_oa_files

  mount_uploader :file, ActivityInsightFileUploader

  scope :ready_for_download, -> {
    left_outer_joins(:publication)
      .where(publication: { publication_type: Publication.oa_publication_types })
      .where.not(publication: { licence: nil })
      .left_outer_joins(publication: :open_access_locations)
      .where(open_access_locations: { publication_id: nil })
      .where(file: nil)
      .where(downloaded: nil)
      .where.not(location: nil)
  }

  def stored_file_path
    file.file.file
  end
end
