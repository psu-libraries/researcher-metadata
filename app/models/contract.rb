class Contract < ApplicationRecord
  has_many :user_contracts, :inverse_of => :contract, dependent: :destroy
  has_many :users, through: :user_contracts
  has_many :imports, class_name: :ContractImport
  has_many :organizations, through: :users

  validates :title, :ospkey, :amount, :sponsor, :status, presence: true

  scope :visible, -> { where visible: true }

  rails_admin do
    list do
      field :id
      field :title
      field :organizations, :has_many_association do
        searchable [:id]
      end
      field :contract_type
      field :status
      field :visible
      field :amount
      field :sponsor
      field :ospkey
      field :award_start_on
      field :award_end_on
      field :created_at
      field :updated_at
    end

    edit do
      field(:visible) { label 'Visible via API?'}
    end
  end
end
