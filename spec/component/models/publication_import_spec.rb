require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe "the publication_imports table", type: :model do
  subject { PublicationImport.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:publication_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:source).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:source_identifier).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:source_updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index([:source_identifier, :source]).unique(true) }
  it { is_expected.to have_db_index(:publication_id) }
  it { is_expected.to have_db_foreign_key(:publication_id) }
end

describe PublicationImport, type: :model do
  subject(:pi) { PublicationImport.new }

  it_behaves_like "an application record"

  it { is_expected.to belong_to(:publication) }

  it { is_expected.to validate_presence_of(:publication) }
  it { is_expected.to validate_presence_of(:source) }
  it { is_expected.to validate_presence_of(:source_identifier) }

  it { is_expected.to validate_inclusion_of(:source).in_array(PublicationImport.sources) }

  context "given an otherwise valid record" do
    subject { build :publication_import }
    it { is_expected.to validate_uniqueness_of(:source_identifier).scoped_to(:source) }
  end

  describe '.sources' do
    it "returns the list of valid publication import sources" do
      expect(PublicationImport.sources).to eq ["Activity Insight", "Pure"]
    end
  end
end
