class UserOrganizationMembership < ApplicationRecord
  belongs_to :user, inverse_of: :user_organization_memberships
  belongs_to :organization, inverse_of: :user_organization_memberships

  validates :user, :organization, presence: true
end
