class Contributor < ApplicationRecord
  belongs_to :publication

  validates :publication, :position, presence: true
end