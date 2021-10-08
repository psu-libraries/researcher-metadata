# frozen_string_literal: true

require 'component/component_spec_helper'

describe 'the user_contracts table', type: :model do
  subject { UserContract.new }

  it { is_expected.to have_db_column(:user_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:contract_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index :user_id }
  it { is_expected.to have_db_index :contract_id }

  it { is_expected.to have_db_foreign_key(:user_id) }
  it { is_expected.to have_db_foreign_key(:contract_id) }
end

describe UserContract, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:user_contracts) }
    it { is_expected.to belong_to(:contract).inverse_of(:user_contracts) }
  end

  describe 'deleting a contract with user_contracts' do
    let(:c) { create :contract }
    let!(:uc) { create :user_contract, contract: c }

    it "also deletes the publication's authorships" do
      c.destroy
      expect { uc.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:contract_id) }

    context 'given otherwise valid data' do
      subject { described_class.new(user: create(:user), contract: create(:contract)) }

      it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:contract_id) }
    end
  end
end
