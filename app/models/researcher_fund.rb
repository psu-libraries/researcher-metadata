# frozen_string_literal: true

class ResearcherFund < ApplicationRecord
  def self.import_sources
    ['NSF', 'NIH']
  end

  belongs_to :grant, inverse_of: :researcher_funds
  belongs_to :user, inverse_of: :researcher_funds

  validates :grant_id, :user_id, presence: true
  validates :import_source, inclusion: { in: import_sources, allow_nil: true }
end
