# frozen_string_literal: true

class Grant < ApplicationRecord
  def self.agency_names
    ['National Science Foundation']
  end

  AGENCY_NAME_MAPPING = {
    'NIH' => [
      'NIH',
      'National Institutes of Health',
      'National Institute of Health',
      'National Institutes of Health (NIH)'
    ],

    'NSF' => [
      'NSF',
      'National Science Foundation',
      'National Science Foundation (NSF)',
      'U.S. National Science Foundation',
      'US National Science Foundation'
    ],

    'NSFC' => [
      'NSFC',
      'National Natural Science Foundation of China',
      'Natural Science Foundation of China',
      'National Natural Science Foundation of China (NSFC)',
      'National Science Foundation of China'
    ],

    'DOE' => [
      'DOE',
      'U.S. Department of Energy',
      'Department of Energy'
    ],

    'NASA' => [
      'NASA'
    ],

    'NHLBI' => [
      'NHLBI',
      'National Heart, Lung, and Blood Institute'
    ],

    'NIMH' => [
      'NIMH',
      'National Institute of Mental Health'
    ],

    'NIDA' => [
      'NIDA',
      'National Institute on Drug Abuse'
    ],

    'NIA' => [
      'NIA',
      'National Institute on Aging'
    ],

    'NICHD' => [
      'NICHD',
      'National Institute of Child Health and Human Development',
      'Eunice Kennedy Shriver National Institute of Child Health and Human Development'
    ]
  }.freeze

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

  def self.find_by_acronym(acronym, fund_num)
    agency_names = AGENCY_NAME_MAPPING[acronym]
    agency_names&.each do |name|
      grant = Grant.find_by(wos_agency_name: name, wos_identifier: fund_num) || Grant.find_by(agency_name: name, identifier: fund_num)
      return grant if grant
    end
    nil
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
