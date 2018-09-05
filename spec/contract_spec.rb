require 'component/component_spec_helper'
  
describe 'the contracts table', type: :model do
  subject { Contract.new }

  it { is_expected.to have_db_column(:title).of_type(:text) }
  it { is_expected.to have_db_column(:contract_type).of_type(:string) }
  it { is_expected.to have_db_column(:sponsor).of_type(:text) }
  it { is_expected.to have_db_column(:amount).of_type(:integer) }
  it { is_expected.to have_db_column(:ospkey).of_type(:integer) }
  it { is_expected.to have_db_column(:award_start_on).of_type(:date) }
  it { is_expected.to have_db_column(:award_end_on).of_type(:date) }

  it { is_expected.to have_db_index(:ospkey) }
end

describe Publication, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:ospkey) }
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:sponsor) }
    it { is_expected.to validate_presence_of(:award_start_on) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:users).through(:user_contracts) }
    it { is_expected.to have_many(:user_contracts).inverse_of(:contract) }
    it { is_expected.to have_many(:imports).class_name(:ContractImport) }
  end

  it { is_expected.to accept_nested_attributes_for(:user_contracts).allow_destroy(true) }

  describe "deleting a contract with user_contracts" do
    let(:c) { create :contract }
    let!(:u) { create :user_contracts, contract: c}
    it "also deletes the contract's user_contracts" do
      c.destroy
      expect { u.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

end
