# frozen_string_literal: true

class Import < ApplicationRecord
  SOURCES = ['Pure', 'Activity Insight'].freeze

  has_many :source_publications

  validates :source, inclusion: { in: SOURCES }
end
