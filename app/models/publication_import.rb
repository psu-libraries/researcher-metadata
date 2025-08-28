# frozen_string_literal: true

class PublicationImport < ApplicationRecord
  def self.sources
    [
      'Activity Insight',
      'Pure',
      'Web of Science',
      'Penn State Law eLibrary Repo',
      'Dickinson Law IDEAS Repo',
      'Insight at Dickinson Law'
    ]
  end

  belongs_to :publication

  validates :publication, :source, :source_identifier, presence: true
  validates :source_identifier, uniqueness: { scope: :source }
  validates :source, inclusion: { in: sources }
end
