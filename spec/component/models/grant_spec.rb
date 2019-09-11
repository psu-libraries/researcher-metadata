require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the grants table', type: :model do
  subject { Grant.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:agency_name).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:identifier).of_type(:string) }
  it { is_expected.to have_db_column(:title).of_type(:text) }
  it { is_expected.to have_db_column(:start_date).of_type(:date) }
  it { is_expected.to have_db_column(:end_date).of_type(:date) }
  it { is_expected.to have_db_column(:amount_in_dollars).of_type(:integer) }
  it { is_expected.to have_db_column(:abstract).of_type(:text) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:identifier) }
end

describe Grant, type: :model do
  subject(:grant) { Grant.new }

  it_behaves_like "an application record"

  it { is_expected.to have_many(:research_funds) }
  it { is_expected.to have_many(:publications).through(:research_funds) }

  it { is_expected.to validate_presence_of(:agency_name) }

  describe '#name' do
    let(:grant) { Grant.new(identifier: 'ID123') }
    it "returns the grant's identifier" do
      expect(grant.name).to eq 'ID123'
    end
  end

  describe "deleting a grant with research funds" do
    let(:g) { create :grant }
    let!(:rf) { create :research_fund, grant: g}
    it "also deletes the grant's research funds" do
      g.destroy
      expect { rf.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
