require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the user_organization_memberships table', type: :model do
  subject { UserOrganizationMembership.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:user_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:organization_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:pure_identifier).of_type(:string) }
  it { is_expected.to have_db_column(:imported_from_pure).of_type(:boolean) }
  it { is_expected.to have_db_column(:position_title).of_type(:string) }
  it { is_expected.to have_db_column(:primary).of_type(:boolean) }
  it { is_expected.to have_db_column(:started_on).of_type(:date) }
  it { is_expected.to have_db_column(:ended_on).of_type(:date) }
  it { is_expected.to have_db_column(:updated_by_user_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:orcid_resource_identifier).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index :user_id }
  it { is_expected.to have_db_index :organization_id }
  it { is_expected.to have_db_index :pure_identifier }

  it { is_expected.to have_db_foreign_key(:user_id) }
  it { is_expected.to have_db_foreign_key(:organization_id) }
end

describe UserOrganizationMembership, type: :model do
  subject { UserOrganizationMembership.new }

  it_behaves_like "an application record"

  it { is_expected.to delegate_method(:organization_name).to(:organization).as(:name) }

  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:user_organization_memberships) }
    it { is_expected.to belong_to(:organization).inverse_of(:user_organization_memberships) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:organization) }
  end

  describe 'name' do
    let(:u) { User.new(first_name: "Sue", last_name: "Tester") }
    let(:o) { Organization.new(name: "Science Department") }
    let(:m) { UserOrganizationMembership.new(user: u, organization: o) }

    it "returns a string with the name of the user and the name of the organization" do
      expect(m.name).to eq "Sue Tester - Science Department"
    end
  end
end
