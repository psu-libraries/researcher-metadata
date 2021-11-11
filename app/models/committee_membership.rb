# frozen_string_literal: true

class CommitteeMembership < ApplicationRecord
  include Comparable

  belongs_to :etd, inverse_of: :committee_memberships
  belongs_to :user, inverse_of: :committee_memberships
  validates :etd_id,
            :user_id,
            :role,
            presence: true

  validates :etd_id, uniqueness: { scope: [:user_id, :role] }
  validates :user_id, uniqueness: { scope: [:etd_id, :role] }
  validate :unknown_role_check

  RANK_LIST = {
    'Dissertation Advisor' => 6,
    'Thesis Advisor' => 5,
    'Committee Chair' => 4,
    'Committee Member' => 3,
    'Outside Member' => 2,
    'Special Member' => 1
  }.freeze

  def <=>(other)
    role_ranking <=> other.role_ranking
  end

  protected

    def role_ranking
      RANK_LIST[role] || 0
    end

    def unknown_role_check
      Bugsnag.notify(I18n.t('models.committee_memberships.unknown_role_message', role: role)) unless RANK_LIST.include? role
    end
end
