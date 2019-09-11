class ResearcherFund < ApplicationRecord
  belongs_to :grant, inverse_of: :researcher_funds
  belongs_to :user, inverse_of: :researcher_funds

  validates :grant_id, :user_id, presence: true
end