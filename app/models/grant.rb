# frozen_string_literal: true

class Grant < ApplicationRecord
  def self.agency_names
    ['NSF', 'NIH']
  end

  def self.import_sources
    ['NSF', 'NIH']
  end

  has_many :research_funds
  has_many :publications, through: :research_funds
  has_many :researcher_funds
  has_many :users, through: :researcher_funds

  validates :identifier, presence: true
  validates :identifier, uniqueness: { scope: :agency_name }
  validates :agency_name, presence: true
  validates :agency_name, inclusion: { in: agency_names }
  validates :import_source, inclusion: { in: import_sources, allow_nil: true }

  def name
    title.presence || identifier.presence
  end

  rails_admin do
    list do
      field(:id)
      field(:title)
      field(:agency_name)
      field(:identifier)
      field(:start_date)
      field(:amount_in_dollars) do
        label 'Amount'
      end
      field(:import_source)
      field(:created_at)
      field(:updated_at)
    end

    show do
      field(:id)
      field(:title)
      field(:agency_name)
      field(:identifier)
      field(:amount_in_dollars)
      field(:abstract)
      field(:start_date)
      field(:end_date)
      field(:publications)
      field(:users)
      field(:import_source)
      field(:created_at)
      field(:updated_at)
    end
  end
end
