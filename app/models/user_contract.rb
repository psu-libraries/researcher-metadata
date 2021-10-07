class UserContract < ApplicationRecord
  belongs_to :user, inverse_of: :user_contracts
  belongs_to :contract, inverse_of: :user_contracts

  validates :user_id, :contract_id, presence: true
  validates :user_id, uniqueness: { scope: :contract_id }
end
