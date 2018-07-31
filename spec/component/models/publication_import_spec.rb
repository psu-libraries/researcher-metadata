require 'component/component_spec_helper'

describe 'the publication_imports table', type: :model do
  subject { PublicationImport.new }

  it { is_expected.to have_db_column(:title).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:publication_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:import_source).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:source_identifier).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:source_updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:publication_type).of_type(:string).with_options(null: false) }
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
  it { is_expected.to have_db_column(:authors_et_al).of_type(:boolean) }
  it { is_expected.to have_db_column(:published_on).of_type(:date) }
  it { is_expected.to have_db_column(:citation_count).of_type(:integer) }
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
  it { is_expected.to have_many(:contributor_imports) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:publication) }
  it { is_expected.to validate_presence_of(:import_source) }
  it { is_expected.to validate_presence_of(:source_identifier) }
  it { is_expected.to validate_presence_of(:publication_type) }

  it { is_expected.to validate_inclusion_of(:import_source).in_array(PublicationImport.import_sources) }
  it { is_expected.to validate_inclusion_of(:publication_type).in_array(PublicationImport.publication_types) }

  context "given an otherwise valid record" do
    subject { build :publication_import }
    it { is_expected.to validate_uniqueness_of(:source_identifier).scoped_to(:import_source) }
  end

  describe '.import_sources' do
    it "returns the list of valid import sources" do
      expect(PublicationImport.import_sources).to eq ["Activity Insight", "Pure"]
    end
  end

  describe '.publication_types' do
    it "returns the list of valid publication types" do
      expect(PublicationImport.publication_types).to eq ["Academic Journal Article"]
    end
  end
end
