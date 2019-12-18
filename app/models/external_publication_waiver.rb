class ExternalPublicationWaiver < ApplicationRecord
  belongs_to :user, inverse_of: :external_publication_waivers

  validates :user, :publication_title, :journal_title, presence: true
end
