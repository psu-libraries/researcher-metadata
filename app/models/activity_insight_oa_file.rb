# frozen_string_literal: true

class ActivityInsightOAFile < ApplicationRecord
  belongs_to :publication,
             inverse_of: :activity_insight_oa_files

  def version_status_display
    return 'Unknown Version' if version == 'unknown'

    'Wrong Version'
  end
end
