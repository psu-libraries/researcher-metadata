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
  it { is_expected.to have_db_column(:pure_uuid).of_type(:string) }
  it { is_expected.to have_db_column(:pure_updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:activity_insight_identifier).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:activity_insight_identifier).unique(true) }
  it { is_expected.to have_db_index(:pure_uuid).unique(true) }
end


describe Publication, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:publication_type) }

    it { is_expected.to validate_inclusion_of(:publication_type).in_array(Publication.publication_types) }

    context "given an otherwise valid record" do
      subject { build :publication }
      it { is_expected.to validate_uniqueness_of(:activity_insight_identifier).allow_nil }
      it { is_expected.to validate_uniqueness_of(:pure_uuid).allow_nil }
    end
  end
  describe 'associations' do
    it { is_expected.to have_many(:authorships) }
    it { is_expected.to have_many(:users).through(:authorships) }
    it { is_expected.to have_many(:contributors) }
  end

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

  describe '.publication_types' do
    it "returns the list of valid publication types" do
      expect(Publication.publication_types).to eq ["Academic Journal Article"]
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
end
