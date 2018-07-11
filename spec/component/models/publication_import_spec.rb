require 'component/component_spec_helper'

describe 'the publication_imports table', type: :model do
  subject { PublicationImport.new }

  it { is_expected.to have_db_column(:title).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:publication_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:import_source).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:source_identifier).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:source_updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:type).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:journal_title).of_type(:text) }
  it { is_expected.to have_db_column(:publisher).of_type(:text) }
  it { is_expected.to have_db_column(:secondary_title).of_type(:text) }
  it { is_expected.to have_db_column(:status).of_type(:string) }
  it { is_expected.to have_db_column(:volume).of_type(:string) }
  it { is_expected.to have_db_column(:issue).of_type(:string) }
  it { is_expected.to have_db_column(:edition).of_type(:string) }
  it { is_expected.to have_db_column(:page_range).of_type(:string) }
  it { is_expected.to have_db_column(:url).of_type(:text) }
  it { is_expected.to have_db_column(:isbn).of_type(:string) }
  it { is_expected.to have_db_column(:issn).of_type(:string) }
  it { is_expected.to have_db_column(:doi).of_type(:string) }
  it { is_expected.to have_db_column(:abstract).of_type(:text) }
  it { is_expected.to have_db_column(:outside_contributors).of_type(:text) }
  it { is_expected.to have_db_column(:authors_et_al).of_type(:boolean) }
  it { is_expected.to have_db_column(:published_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index :source_identifier }
  it { is_expected.to have_db_index :import_source }
  it { is_expected.to have_db_index :publication_id }

  it { is_expected.to have_db_foreign_key :publication_id }
end

describe PublicationImport, type: :model do
  subject(:import) { PublicationImport.new }

  it { is_expected.to belong_to(:publication) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:publication) }
  it { is_expected.to validate_presence_of(:import_source) }
  it { is_expected.to validate_presence_of(:source_identifier) }
  it { is_expected.to validate_presence_of(:type) }

  it { is_expected.to serialize(:outside_contributors) }
end