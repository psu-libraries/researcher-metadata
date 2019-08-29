class Organization < ApplicationRecord
  belongs_to :parent, class_name: :Organization, optional: true
  belongs_to :owner, class_name: :User, optional: true
  has_many :children, class_name: :Organization, foreign_key: :parent_id
  has_many :user_organization_memberships, inverse_of: :organization
  has_many :users, through: :user_organization_memberships
  has_many :publications, -> { published_during_membership }, through: :users

  validates :name, presence: true

  scope :visible, -> { where(visible: true) }

  rails_admin do
    list do
      field(:id)
      field(:name)
      field(:visible)
      field(:pure_uuid)
      field(:pure_external_identifier)
      field(:organization_type)
      field(:owner)
    end

    show do
      field(:id)
      field(:name)
      field(:visible)
      field(:pure_uuid)
      field(:pure_external_identifier)
      field(:organization_type)
      field(:owner)
      field(:parent)
      field(:children)
      field(:users)
      field(:user_organization_memberships)
    end
  end
end
