class InternalPublicationWaiver < ApplicationRecord
  belongs_to :authorship, inverse_of: :waiver

  delegate :title, :abstract, :doi, :published_by, to: :authorship, prefix: false
end
