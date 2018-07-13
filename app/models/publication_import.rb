class PublicationImport < ApplicationRecord
  def self.import_sources
    ["Activity Insight"]
  end

  def self.publication_types
    ["Academic Journal Article"]
  end

  belongs_to :publication
  has_many :contributor_imports

  validates :title, :publication, :import_source, :source_identifier, :publication_type, presence: true
  validates :import_source, inclusion: {in: import_sources}
  validates :publication_type, inclusion: {in: publication_types}
  validates :source_identifier, uniqueness: {scope: :import_source}
end
