class Organization < ApplicationRecord
  belongs_to :parent, class_name: :Organization, optional: true
  has_many :children, class_name: :Organization, foreign_key: :parent_id
  has_many :user_organization_memberships, inverse_of: :organization
  has_many :users, through: :user_organization_memberships

  validates :name, presence: true
end