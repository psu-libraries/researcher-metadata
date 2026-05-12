# frozen_string_literal: true

class ResearchFund < ApplicationRecord
  def self.import_sources
    ['NSF', 'NIH', 'Pure']
  end

  belongs_to :grant, inverse_of: :research_funds
  belongs_to :publication, inverse_of: :research_funds

  validates :grant_id, :publication_id, presence: true
  validates :import_source, inclusion: { in: import_sources }
  validates :import_source, presence: true
end
