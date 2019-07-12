require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the organizations table', type: :model do
  subject { Organization.new }

  it { is_expected.to have_db_column(:name).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:visible).of_type(:boolean) }
  it { is_expected.to have_db_column(:pure_uuid).of_type(:string) }
  it { is_expected.to have_db_column(:pure_external_identifier).of_type(:string) }
  it { is_expected.to have_db_column(:organization_type).of_type(:string) }
  it { is_expected.to have_db_column(:parent_id).of_type(:integer) }
  it { is_expected.to have_db_column(:owner_id).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:pure_uuid).unique(true) }
  it { is_expected.to have_db_index(:parent_id) }
  it { is_expected.to have_db_index(:owner_id) }
  it { is_expected.to have_db_foreign_key(:parent_id).to_table(:organizations) }
  it { is_expected.to have_db_foreign_key(:owner_id).to_table(:users) }
end

describe Organization, type: :model do
  it_behaves_like "an application record"

  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to belong_to(:parent).class_name(:Organization).optional }
  it { is_expected.to belong_to(:owner).class_name(:User).optional }
  it { is_expected.to have_many(:children).class_name(:Organization) }
  it { is_expected.to have_many(:user_organization_memberships).inverse_of(:organization) }
  it { is_expected.to have_many(:users).through(:user_organization_memberships) }

  describe "deleting an organization with user memberships" do
    let(:o) { create :organization }
    let!(:m) { create :user_organization_membership, organization: o}
    it "also deletes the organization's user memberships" do
      o.destroy
      expect { m.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '.visible' do
    let!(:org1) { create :organization, visible: false }
    let!(:org2) { create :organization, visible: true }

    it "returns a collection of the visible organizations" do
      expect(Organization.visible).to eq [org2]
    end
  end

  describe '#publications' do
    let!(:org) { create :organization }
    let!(:other_org) { create :organization }
    let!(:user_1) { create :user }
    let!(:user_2) { create :user }
    let!(:user_3) { create :user }

    let!(:pub_1) { create :publication, visible: true, published_on: Date.new(2000, 1, 1) }
    let!(:pub_2) { create :publication, visible: true, published_on: Date.new(2005, 1, 2) }
    let!(:pub_3) { create :publication, visible: true, published_on: Date.new(1999, 12, 30) }
    let!(:pub_4) { create :publication, visible: true, published_on: Date.new(2001, 1, 1) }
    let!(:pub_5) { create :publication, visible: true, published_on: Date.new(2001, 1, 1) }
    let!(:pub_6) { create :publication, visible: true, published_on: Date.new(2001, 1, 1) }
    let!(:pub_7) { create :publication, visible: true, published_on: Date.new(2019, 1, 1) }
    let!(:pub_8) { create :publication, visible: false, published_on: Date.new(2019, 1, 1) }

    before do
      create :authorship, user: user_1, publication: pub_1
      create :authorship, user: user_2, publication: pub_1
      create :authorship, user: user_1, publication: pub_2
      create :authorship, user: user_2, publication: pub_3
      create :authorship, user: user_1, publication: pub_4
      create :authorship, user: user_2, publication: pub_5
      create :authorship, user: user_3, publication: pub_6
      create :authorship, user: user_1, publication: pub_7
      create :authorship, user: user_1, publication: pub_8

      create :user_organization_membership,
             user: user_1,
             organization: org,
             started_on: Date.new(1990, 1, 1),
             ended_on: Date.new(2005, 1, 1)
      create :user_organization_membership,
             user: user_1,
             organization: org,
             started_on: Date.new(2015, 1, 1)
      create :user_organization_membership,
             user: user_2,
             organization: org,
             started_on: Date.new(1999, 12, 31)
      create :user_organization_membership,
             user: user_3,
             organization: other_org,
             started_on: Date.new(1980, 1, 1)
    end
    it "returns publications by users who were members of the organization when they were published" do
      expect(org.publications).to match_array [pub_1, pub_4, pub_5, pub_7]
    end
  end
end
