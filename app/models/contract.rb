class Contract < ApplicationRecord
  has_many :user_contracts, :inverse_of => :contract, dependent: :destroy
  has_many :users, through: :user_contracts
  has_many :imports, class_name: :ContractImport

  validates :title, :ospkey, :amount, :sponsor, :award_start_on, presence: true
end
