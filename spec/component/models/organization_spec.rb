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
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:pure_uuid).unique(true) }
  it { is_expected.to have_db_index(:parent_id) }
  it { is_expected.to have_db_foreign_key(:parent_id).to_table(:organizations) }
end

describe Organization, type: :model do
  it_behaves_like "an application record"

  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to belong_to(:parent).class_name(:Organization).optional }
  it { is_expected.to have_many(:children).class_name(:Organization) }
end
