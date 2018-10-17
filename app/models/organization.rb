class Organization < ApplicationRecord
  belongs_to :parent, class_name: :Organization
  has_many :children, class_name: :Organization, foreign_key: :parent_id
  validates :name, presence: true
end