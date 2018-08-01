class Authorship < ApplicationRecord
  belongs_to :user
  belongs_to :publication
  validates :user_id,
    :publication_id,
    :author_number, presence: true

  validates :user_id, uniqueness: {scope: :publication_id}
  validates :pure_identifier, :activity_insight_identifier, uniqueness: { allow_nil: true }
end
