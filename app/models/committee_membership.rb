class CommitteeMembership < ApplicationRecord
  include Comparable

  belongs_to :etd, inverse_of: :committee_memberships
  belongs_to :user, inverse_of: :committee_memberships
  validates :etd_id,
            :user_id,
            :role,
            presence: true

  validates :etd_id, uniqueness: {scope: [:user_id, :role]}
  validates :user_id, uniqueness: {scope: [:etd_id, :role]}

  def <=>(other)
    role_ranking <=> other.role_ranking
  end

  protected

  def role_ranking
    rank_list = {
      'Dissertation Advisor' => 5,
      'Committee Chair' => 4,
      'Committee Member' => 3,
      'Outside Member' => 2,
      'Special Member' => 1
    }

    rank_list[role]
  end
end
