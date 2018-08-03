class PublicationImport < ApplicationRecord
  def self.sources
    ["Activity Insight", "Pure"]
  end

  belongs_to :publication

  validates :publication, :source, :source_identifier, presence: true
  validates :source_identifier, uniqueness: {scope: :source}
  validates :source, inclusion: {in: sources}
end