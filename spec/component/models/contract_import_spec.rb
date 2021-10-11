# frozen_string_literal: true

require 'component/component_spec_helper'

describe 'the contract_imports table', type: :model do
  subject { ContractImport.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:contract_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:activity_insight_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:activity_insight_id).unique(true) }
  it { is_expected.to have_db_index(:contract_id) }
  it { is_expected.to have_db_foreign_key(:contract_id) }
end

describe ContractImport, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:contract) }
    it { is_expected.to validate_presence_of(:activity_insight_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:contract) }
  end
end
