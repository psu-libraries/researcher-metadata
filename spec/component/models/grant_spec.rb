require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the grants table', type: :model do
  subject { Grant.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:wos_agency_name).of_type(:text).with_options(null: true) }
  it { is_expected.to have_db_column(:wos_identifier).of_type(:string) }
  it { is_expected.to have_db_column(:agency_name).of_type(:text) }
  it { is_expected.to have_db_column(:identifier).of_type(:string) }
  it { is_expected.to have_db_column(:title).of_type(:text) }
  it { is_expected.to have_db_column(:start_date).of_type(:date) }
  it { is_expected.to have_db_column(:end_date).of_type(:date) }
  it { is_expected.to have_db_column(:amount_in_dollars).of_type(:integer) }
  it { is_expected.to have_db_column(:abstract).of_type(:text) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:wos_identifier) }
  it { is_expected.to have_db_index(:wos_agency_name) }
  it { is_expected.to have_db_index(:identifier) }
  it { is_expected.to have_db_index(:agency_name) }
end

describe Grant, type: :model do
  subject(:grant) { Grant.new }

  it_behaves_like "an application record"

  it { is_expected.to have_many(:research_funds) }
  it { is_expected.to have_many(:publications).through(:research_funds) }
  it { is_expected.to have_many(:researcher_funds) }
  it { is_expected.to have_many(:users).through(:researcher_funds) }

  describe '#name' do
    let(:grant) { Grant.new(wos_identifier: wos_id, identifier: id) }
    context "when the grant has a canonical identifier" do
      let(:id) { 'CID123' }
      context "when the grant has a Web of Science identifier" do
        let(:wos_id) { 'WOSID456' }
        it "returns the canonical identifier" do
          expect(grant.name).to eq  'CID123'
        end
      end
      context "when the grant's Web of Science identifier is blank" do
        let(:wos_id) { '' }
        it "returns the canonical identifier" do
          expect(grant.name).to eq  'CID123'
        end
      end
      context "when the grant has no Web of Science identifier" do
        let(:wos_id) { nil }
        it "returns the canonical identifier" do
          expect(grant.name).to eq  'CID123'
        end
      end
    end
    context "when the grant's canonical identifier is blank" do
      let(:id) { '' }
      context "when the grant has a Web of Science identifier" do
        let(:wos_id) { 'WOSID456' }
        it "returns the Web of Science identifier" do
          expect(grant.name).to eq 'WOSID456'
        end
      end
      context "when the grant's Web of Science identifier is blank" do
        let(:wos_id) { '' }
        it "returns nil" do
          expect(grant.name).to eq nil
        end
      end
      context "when the grant has no Web of Science identifier" do
        let(:wos_id) { nil }
        it "returns nil" do
          expect(grant.name).to eq nil
        end
      end
    end
    context "when the grant has no canonical identifier" do
      let(:id) { nil }
      context "when the grant has a Web of Science identifier" do
        let(:wos_id) { 'WOSID456' }
        it "returns the Web of Science identifier" do
          expect(grant.name).to eq 'WOSID456'
        end
      end
      context "when the grant's Web of Science identifier is blank" do
        let(:wos_id) { '' }
        it "returns nil" do
          expect(grant.name).to eq nil
        end
      end
      context "when the grant has no Web of Science identifier" do
        let(:wos_id) { nil }
        it "returns nil" do
          expect(grant.name).to eq nil
        end
      end
    end
  end

  describe '#agency' do
    let(:grant) { Grant.new(wos_agency_name: wos_an, agency_name: an) }
    context "when the grant has a canonical agency name" do
      let(:an) { 'Canonical Name' }
      context "when the grant has a Web of Science agency name" do
        let(:wos_an) { 'WOS Name' }
        it "returns the canonical agency name" do
          expect(grant.agency).to eq  'Canonical Name'
        end
      end
      context "when the grant's Web of Science agency name is blank" do
        let(:wos_an) { '' }
        it "returns the canonical agency name" do
          expect(grant.agency).to eq  'Canonical Name'
        end
      end
      context "when the grant has no Web of Science agency name" do
        let(:wos_an) { nil }
        it "returns the canonical agency name" do
          expect(grant.agency).to eq  'Canonical Name'
        end
      end
    end
    context "when the grant's canonical agency name is blank" do
      let(:an) { '' }
      context "when the grant has a Web of Science agency name" do
        let(:wos_an) { 'WOS Name' }
        it "returns the Web of Science agency name" do
          expect(grant.agency).to eq 'WOS Name'
        end
      end
      context "when the grant's Web of Science agency name is blank" do
        let(:wos_an) { '' }
        it "returns nil" do
          expect(grant.agency).to eq nil
        end
      end
      context "when the grant has no Web of Science agency name" do
        let(:wos_an) { nil }
        it "returns nil" do
          expect(grant.agency).to eq nil
        end
      end
    end
    context "when the grant has no canonical agency name" do
      let(:an) { nil }
      context "when the grant has a Web of Science agency name" do
        let(:wos_an) { 'WOS Name' }
        it "returns the Web of Science agency name" do
          expect(grant.agency).to eq 'WOS Name'
        end
      end
      context "when the grant's Web of Science agency name is blank" do
        let(:wos_an) { '' }
        it "returns nil" do
          expect(grant.agency).to eq nil
        end
      end
      context "when the grant has no Web of Science agency name" do
        let(:wos_an) { nil }
        it "returns nil" do
          expect(grant.agency).to eq nil
        end
      end
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

  describe "deleting a grant with researcher funds" do
    let(:g) { create :grant }
    let!(:rf) { create :researcher_fund, grant: g}
    it "also deletes the grant's researcher funds" do
      g.destroy
      expect { rf.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
