require 'component/component_spec_helper'

describe 'the user_organization_memberships table', type: :model do
  subject { UserOrganizationMembership.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:user_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:organization_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:pure_identifier).of_type(:string) }
  it { is_expected.to have_db_column(:imported_from_pure).of_type(:boolean) }
  it { is_expected.to have_db_column(:position_title).of_type(:string) }
  it { is_expected.to have_db_column(:primary).of_type(:boolean) }
  it { is_expected.to have_db_column(:updated_by_user_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index :user_id }
  it { is_expected.to have_db_index :organization_id }
  it { is_expected.to have_db_index :pure_identifier }

  it { is_expected.to have_db_foreign_key(:user_id) }
  it { is_expected.to have_db_foreign_key(:organization_id) }
end

describe UserOrganizationMembership, type: :model do
  it_behaves_like "an application record"

  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:user_organization_memberships) }
    it { is_expected.to belong_to(:organization).inverse_of(:user_organization_memberships) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:organization) }
  end
end
