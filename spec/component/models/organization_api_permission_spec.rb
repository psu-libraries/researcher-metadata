require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the organization_api_permissions table', type: :model do
  subject { OrganizationAPIPermission.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:api_token_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:organization_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index :api_token_id }
  it { is_expected.to have_db_index :organization_id }

  it { is_expected.to have_db_foreign_key(:api_token_id) }
  it { is_expected.to have_db_foreign_key(:organization_id) }
end

describe OrganizationAPIPermission, type: :model do
  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to belong_to(:api_token).inverse_of(:organization_api_permissions) }
    it { is_expected.to belong_to(:organization) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:api_token) }
    it { is_expected.to validate_presence_of(:organization) }
  end
end
