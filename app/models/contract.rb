class Contract < ApplicationRecord
  has_many :user_contracts, :inverse_of => :contract, dependent: :destroy
  has_many :users, through: :user_contracts
  has_many :imports, class_name: :ContractImport
  has_many :organizations, through: :users

  validates :title, :ospkey, :amount, :sponsor, :status, presence: true

  scope :visible, -> { where visible: true }
end
