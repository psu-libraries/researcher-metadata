# frozen_string_literal: true

class PerformanceScreening < ApplicationRecord
  belongs_to :performance

  validates :performance, :activity_insight_id, presence: true
  validates :activity_insight_id, uniqueness: true
end
