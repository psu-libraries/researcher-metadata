class ContributorImport < ApplicationRecord
  belongs_to :publication_import

  validates :publication_import, :position,
            :import_source, :source_identifier, presence: true

  validates :import_source, inclusion: {in: PublicationImport.import_sources}
  validates :source_identifier, uniqueness: {scope: :import_source}
end