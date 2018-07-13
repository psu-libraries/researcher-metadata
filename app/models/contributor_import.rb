class ContributorImport < ApplicationRecord
  belongs_to :publication_import

  validates :publication_import, :position, presence: true
end