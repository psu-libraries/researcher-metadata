class Authorship < ApplicationRecord
  belongs_to :user
  belongs_to :publication
  validates :user_id,
    :publication_id,
    :author_number, presence: true
end
