require 'component/component_spec_helper'
  
describe 'the contracts table', type: :model do
  subject { Contract.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:title).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:contract_type).of_type(:string) }
  it { is_expected.to have_db_column(:sponsor).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:status).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:amount).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:ospkey).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:award_start_on).of_type(:date) }
  it { is_expected.to have_db_column(:award_end_on).of_type(:date) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:visible).of_type(:boolean).with_options(default: false) }

  it { is_expected.to have_db_index(:ospkey).unique(true) }
end

describe Contract, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:ospkey) }
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:sponsor) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:users).through(:user_contracts) }
    it { is_expected.to have_many(:user_contracts).inverse_of(:contract) }
    it { is_expected.to have_many(:imports).class_name(:ContractImport) }
    it { is_expected.to have_many(:organizations).through(:users) }
  end

  describe "deleting a contract with user_contracts" do
    let(:c) { create :contract }
    let!(:u) { create :user_contract, contract: c}
    it "also deletes the contract's user_contracts" do
      c.destroy
      expect { u.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "deleting a contract with contract_imports" do
    let(:c) { create :contract }
    let!(:ci) { create :contract_import, contract: c}
    it "also deletes the contract's contract_imports" do
      c.destroy
      expect { ci.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '.visible' do
    let(:visible_contract1) { create :contract, visible: true }
    let(:visible_contract2) { create :contract, visible: true }
    let(:invisible_contract) { create :contract, visible: false }
    it "returns the contracts that are marked as visible" do
      expect(Contract.visible).to match_array [visible_contract1, visible_contract2]
    end
  end
end
