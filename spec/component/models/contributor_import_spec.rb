require 'component/component_spec_helper'

describe 'the contributor_imports_table', type: :model do
  subject { ContributorImport.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:publication_import_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:first_name).of_type(:string) }
  it { is_expected.to have_db_column(:middle_name).of_type(:string) }
  it { is_expected.to have_db_column(:last_name).of_type(:string) }
  it { is_expected.to have_db_column(:position).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_foreign_key(:publication_import_id) }
  it { is_expected.to have_db_index(:publication_import_id) }
end

describe ContributorImport, type: :model do
  it { is_expected.to validate_presence_of :publication_import }
  it { is_expected.to validate_presence_of :position }

  it { is_expected.to belong_to :publication_import }
end