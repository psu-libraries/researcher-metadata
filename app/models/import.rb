# frozen_string_literal: true

class Import < ApplicationRecord
  SOURCES = ['Pure', 'Activity Insight'].freeze

  has_many :source_publications

  validates :source, inclusion: { in: SOURCES }

  def self.latest_completed_from_pure
    where(source: 'Pure').where.not(completed_at: nil).order(:completed_at).last
  end

  def self.latest_completed_from_ai
    where(source: 'Activity Insight').where.not(completed_at: nil).order(:completed_at).last
  end
end
