class PublicationImport < ApplicationRecord
  belongs_to :publication

  validates :title, :publication, :import_source, :source_identifier, :type, presence: true

  serialize :outside_contributors, Hash
end