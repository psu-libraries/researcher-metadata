class Organization < ApplicationRecord
  belongs_to :parent, class_name: :Organization, optional: true
  belongs_to :owner, class_name: :User, optional: true
  has_many :children, class_name: :Organization, foreign_key: :parent_id
  has_many :user_organization_memberships, inverse_of: :organization
  has_many :users, through: :user_organization_memberships
  has_many :pubs, through: :users, source: :publications

  validates :name, presence: true

  scope :visible, -> { where(visible: true) }

  def publications
    pubs.
      visible.
      joins(:user_organization_memberships).
      where('published_on >= user_organization_memberships.started_on AND (published_on <= user_organization_memberships.ended_on OR user_organization_memberships.ended_on IS NULL)').
      distinct(:id)
  end
end
