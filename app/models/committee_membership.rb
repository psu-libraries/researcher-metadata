class CommitteeMembership < ApplicationRecord
  belongs_to :etd, inverse_of: :committee_memberships
  belongs_to :user, inverse_of: :committee_memberships
  validates :etd_id,
            :user_id,
            :role,
            presence: true

  validates :etd_id, uniqueness: {scope: :user_id}
  validates :user_id, uniqueness: {scope: :etd_id}
end
