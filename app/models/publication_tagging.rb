class PublicationTagging < ApplicationRecord
  belongs_to :tag, inverse_of: :publication_taggings
  belongs_to :publication, inverse_of: :taggings
  validates :tag_id,
    :publication_id, presence: true

  validates :tag_id, uniqueness: {scope: :publication_id}
  validates :publication_id, uniqueness: {scope: :tag_id}

  delegate :name, to: :tag
end
