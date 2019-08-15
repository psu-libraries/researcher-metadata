require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

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
  it { is_expected.to have_db_column(:total_scopus_citations).of_type(:integer) }
  it { is_expected.to have_db_column(:duplicate_publication_group_id).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_by_user_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:visible).of_type(:boolean).with_options(default: false) }

  it { is_expected.to have_db_foreign_key(:duplicate_publication_group_id) }

  it { is_expected.to have_db_index(:duplicate_publication_group_id) }
  it { is_expected.to have_db_index(:volume) }
  it { is_expected.to have_db_index(:issue) }
end


describe Publication, type: :model do
  it_behaves_like "an application record"

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
    it { is_expected.to have_many(:organizations).through(:users) }
    it { is_expected.to have_many(:user_organization_memberships).through(:users) }

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

  describe '.visible' do
    let(:visible_pub1) { create :publication, visible: true }
    let(:visible_pub2) { create :publication, visible: true }
    let(:invisible_pub) { create :publication, visible: false }
    it "returns the publications that are marked as visible" do
      expect(Publication.visible).to match_array [visible_pub1, visible_pub2]
    end
  end

  describe '.published_during_membership' do
    let!(:org) { create :organization }
    let!(:other_org) { create :organization }
    let!(:user_1) { create :user }
    let!(:user_2) { create :user }
    let!(:user_3) { create :user }

    let!(:pub_1) { create :publication, visible: true, published_on: Date.new(2000, 1, 1) }
    let!(:pub_2) { create :publication, visible: true, published_on: Date.new(2005, 1, 2) }
    let!(:pub_3) { create :publication, visible: true, published_on: Date.new(1999, 12, 30) }
    let!(:pub_4) { create :publication, visible: true, published_on: Date.new(2001, 1, 1) }
    let!(:pub_5) { create :publication, visible: true, published_on: Date.new(2001, 1, 1) }
    let!(:pub_6) { create :publication, visible: true, published_on: Date.new(2001, 1, 1) }
    let!(:pub_7) { create :publication, visible: true, published_on: Date.new(2019, 1, 1) }
    let!(:pub_8) { create :publication, visible: false, published_on: Date.new(2019, 1, 1) }

    before do
      create :authorship, user: user_1, publication: pub_1 # authored by an org member during their first membership
      create :authorship, user: user_2, publication: pub_1 # also authored by second org member during their membership
      create :authorship, user: user_1, publication: pub_2 # authored by an org member after their membership
      create :authorship, user: user_2, publication: pub_3 # authored by an org member before their membership
      create :authorship, user: user_1, publication: pub_4 # authored by an org member during their first membership
      create :authorship, user: user_2, publication: pub_5 # authored by an org member during their membership
      create :authorship, user: user_3, publication: pub_6 # authored by an org member during their membership
      create :authorship, user: user_1, publication: pub_7 # authored by an org member during their second membership
      create :authorship, user: user_1, publication: pub_8 # authored by an org member during their second membership, but invisible

      create :user_organization_membership,
             user: user_1,
             organization: org,
             started_on: Date.new(1990, 1, 1),
             ended_on: Date.new(2005, 1, 1)
      create :user_organization_membership,
             user: user_1,
             organization: org,
             started_on: Date.new(2015, 1, 1)
      create :user_organization_membership,
             user: user_2,
             organization: org,
             started_on: Date.new(1999, 12, 31)
      create :user_organization_membership,
             user: user_3,
             organization: other_org,
             started_on: Date.new(1980, 1, 1)
    end
    it "returns visible, unique publications by users who were members of an organization when they were published" do
      expect(Publication.published_during_membership).to match_array [pub_1, pub_4, pub_5, pub_6, pub_7]
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

  describe '#mark_as_updated_by_user' do
    let(:pub) { Publication.new }
    before { allow(Time).to receive(:current).and_return Time.new(2018, 8, 23, 10, 7, 0) }

    it "sets the user's updated_by_user_at field to the current time" do
      pub.mark_as_updated_by_user
      expect(pub.updated_by_user_at).to eq Time.new(2018, 8, 23, 10, 7, 0)
    end
  end

  describe '#year' do
    context "when the publication does not have a published_on date" do
      let(:pub) { Publication.new(published_on: nil) }

      it "returns nil" do
        expect(pub.year).to be_nil
      end
    end

    context "when the publication has a published_on date" do
      let(:pub) { Publication.new(published_on: Date.new(2001, 1, 2)) }

      it "returns the year of the publication date" do
        expect(pub.year).to eq 2001
      end
    end
  end

  describe '#published_by' do
    let(:pub) { Publication.new(publisher: publisher, journal_title: jt) }
    context "when the publication has a journal title" do
      let(:jt) { "The Journal" }
      context "when the publication has a publisher" do
        let(:publisher) { "The Publisher" }

        it "returns the journal title" do
          expect(pub.published_by).to eq "The Journal"
        end
      end

      context "when the publication does not have a publisher" do
        let(:publisher) { nil }

        it "returns the journal title" do
          expect(pub.published_by).to eq "The Journal"
        end
      end

      context "when the publication's publisher is blank" do
        let(:publisher) { "" }

        it "returns the journal title" do
          expect(pub.published_by).to eq "The Journal"
        end
      end
    end

    context "when the publication does not have a journal title" do
      let(:jt) { nil }
      context "when the publication has a publisher" do
        let(:publisher) { "The Publisher" }

        it "returns the publisher" do
          expect(pub.published_by).to eq "The Publisher"
        end
      end

      context "when the publication does not have a publisher" do
        let(:publisher) { nil }

        it "returns nil" do
          expect(pub.published_by).to be_nil
        end
      end

      context "when the publication's publisher is blank" do
        let(:publisher) { "" }

        it "returns nil" do
          expect(pub.published_by).to be_nil
        end
      end
    end

    context "when the publication's journal title is blank" do
      let(:jt) { "" }
      context "when the publication has a publisher" do
        let(:publisher) { "The Publisher" }

        it "returns the publisher" do
          expect(pub.published_by).to eq "The Publisher"
        end
      end

      context "when the publication does not have a publisher" do
        let(:publisher) { nil }

        it "returns nil" do
          expect(pub.published_by).to be_nil
        end
      end

      context "when the publication's publisher is blank" do
        let(:publisher) { "" }

        it "returns nil" do
          expect(pub.published_by).to be_nil
        end
      end
    end
  end
end
