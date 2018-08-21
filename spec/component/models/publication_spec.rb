require 'component/component_spec_helper'

describe 'the publications table', type: :model do
  subject { Publication.new }

  it { is_expected.to have_db_column(:title).of_type(:text).with_options(null: false) }
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
  it { is_expected.to have_db_column(:duplicate_publication_group_id).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_by_user_at).of_type(:datetime) }

  it { is_expected.to have_db_foreign_key(:duplicate_publication_group_id) }

  it { is_expected.to have_db_index(:duplicate_publication_group_id) }
  it { is_expected.to have_db_index(:volume) }
  it { is_expected.to have_db_index(:issue) }
end


describe Publication, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:publication_type) }

    it { is_expected.to validate_inclusion_of(:publication_type).in_array(Publication.publication_types) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:authorships).inverse_of(:publication) }
    it { is_expected.to have_many(:users).through(:authorships) }
    it { is_expected.to have_many(:contributors).dependent(:destroy).inverse_of(:publication) }
    it { is_expected.to have_many(:imports).class_name(:PublicationImport) }
    it { is_expected.to have_many(:taggings).inverse_of(:publication).class_name(:PublicationTagging) }
    it { is_expected.to have_many(:tags).through(:taggings) }

    it { is_expected.to belong_to(:duplicate_group).class_name(:DuplicatePublicationGroup).optional.inverse_of(:publications) }
  end

  it { is_expected.to accept_nested_attributes_for(:authorships).allow_destroy(true) }
  it { is_expected.to accept_nested_attributes_for(:contributors).allow_destroy(true) }
  it { is_expected.to accept_nested_attributes_for(:taggings).allow_destroy(true) }

  describe "deleting a publication with authorships" do
    let(:p) { create :publication }
    let!(:a) { create :authorship, publication: p}
    it "also deletes the publication's authorships" do
      p.destroy
      expect { a.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "deleting a publication with contributors" do
    let(:p) { create :publication }
    let!(:c) { create :contributor, publication: p}
    it "also deletes the publication's authorships" do
      p.destroy
      expect { c.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "deleting a publication with taggings" do
    let(:p) { create :publication }
    let!(:pt) { create :publication_tagging, publication: p}
    it "also deletes the publication's taggings" do
      p.destroy
      expect { pt.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '.publication_types' do
    it "returns the list of valid publication types" do
      expect(Publication.publication_types).to eq ["Academic Journal Article",
                                                   "In-house Journal Article",
                                                   "Professional Journal Article",
                                                   "Trade Journal Article",
                                                   "Journal Article"]
    end
  end

  describe '#contributors' do
    let(:pub) { create :publication }
    let!(:c1) { create :contributor, position: 2, publication: pub }
    let!(:c2) { create :contributor, position: 3, publication: pub }
    let!(:c3) { create :contributor, position: 1, publication: pub }

    it "returns the publication's contributors in order by position" do
      expect(pub.contributors).to eq [c3, c1, c2]
    end
  end

  describe '#ai_import_identifiers' do
    let(:pub) { create :publication }

    before { create :publication_import,
                    source: "Pure",
                    source_identifier: "pure-abc123",
                    publication: pub }

    context "when the publication does not have imports from Activity Insight" do
      it "returns an empty array" do
        expect(pub.ai_import_identifiers).to eq []
      end
    end
    context "when the publication has imports from Activity Insight" do
      before do
        create :publication_import,
               source: "Activity Insight",
               source_identifier: "ai-abc123",
               publication: pub
        create :publication_import,
               source: "Activity Insight",
               source_identifier: "ai-xyz789",
               publication: pub
      end

      it "returns an array of the source identifiers from the publication's Activity Insight imports" do
        expect(pub.ai_import_identifiers).to match_array ["ai-abc123", "ai-xyz789"]
      end
    end
  end

  describe '#pure_import_identifiers' do
    let(:pub) { create :publication }

    before { create :publication_import,
                    source: "Activity Insight",
                    source_identifier: "ai-abc123",
                    publication: pub }

    context "when the publication does not have imports from Pure" do
      it "returns an empty array" do
        expect(pub.pure_import_identifiers).to eq []
      end
    end
    context "when the publication has imports from Pure" do
      before do
        create :publication_import,
               source: "Pure",
               source_identifier: "pure-abc123",
               publication: pub
        create :publication_import,
               source: "Pure",
               source_identifier: "pure-xyz789",
               publication: pub
      end

      it "returns an array of the source identifiers from the publication's Pure imports" do
        expect(pub.pure_import_identifiers).to match_array ["pure-abc123", "pure-xyz789"]
      end
    end
  end
end
