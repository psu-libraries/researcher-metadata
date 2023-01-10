# frozen_string_literal: true

class ActivityInsightOaFile < ApplicationRecord
  belongs_to :publication,
             inverse_of: :activity_insight_oa_file
end
