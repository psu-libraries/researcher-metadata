class Grant < ApplicationRecord
  validates :agency_name, presence: true

  has_many :research_funds
  has_many :publications, through: :research_funds
end
