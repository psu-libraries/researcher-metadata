class Authorship < ApplicationRecord
  belongs_to :user, inverse_of: :authorships
  belongs_to :publication, inverse_of: :authorships
  validates :user_id,
    :publication_id,
    :author_number, presence: true

  validates :user_id, uniqueness: {scope: :publication_id}
end
