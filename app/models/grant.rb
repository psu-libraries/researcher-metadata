class Grant < ApplicationRecord
  has_many :research_funds
  has_many :publications, through: :research_funds
  has_many :researcher_funds
  has_many :users, through: :researcher_funds

  def name
    wos_identifier
  end

  rails_admin do
    list do
      field(:id)
      field(:wos_agency_name)
      field(:wos_identifier)
      field(:created_at)
      field(:updated_at)
    end

    show do
      field(:id)
      field(:title)
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
