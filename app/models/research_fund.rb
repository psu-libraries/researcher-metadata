# frozen_string_literal: true

class ResearchFund < ApplicationRecord
  belongs_to :grant, inverse_of: :research_funds
  belongs_to :publication, inverse_of: :research_funds

  validates :grant_id, :publication_id, presence: true
end
