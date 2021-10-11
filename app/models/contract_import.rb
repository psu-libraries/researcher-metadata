# frozen_string_literal: true

class ContractImport < ApplicationRecord
  belongs_to :contract

  validates :contract, :activity_insight_id, presence: true
end
