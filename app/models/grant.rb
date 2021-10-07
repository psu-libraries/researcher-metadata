class Grant < ApplicationRecord
  def self.agency_names
    ['National Science Foundation']
  end

  has_many :research_funds
  has_many :publications, through: :research_funds
  has_many :researcher_funds
  has_many :users, through: :researcher_funds

  validates :agency_name, inclusion: { in: agency_names, allow_nil: true }

  def name
    title.presence || identifier.presence || wos_identifier.presence
  end

  def agency
    agency_name.presence || wos_agency_name.presence
  end

  rails_admin do
    list do
      field(:id)
      field(:agency)
      field(:name) do
        label 'Identifier'
      end
      field(:created_at)
      field(:updated_at)
    end

    show do
      field(:id)
      field(:title)
      field(:agency_name)
      field(:identifier)
      field(:wos_agency_name)
      field(:wos_identifier)
      field(:amount_in_dollars)
      field(:abstract)
      field(:start_date)
      field(:end_date)
      field(:publications)
      field(:users)
      field(:created_at)
      field(:updated_at)
    end
  end
end
