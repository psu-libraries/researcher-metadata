require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the publications table', type: :model do
  subject { Publication.new }

  it { is_expected.to have_db_column(:title).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:publication_type).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:journal_title).of_type(:text) }
  it { is_expected.to have_db_column(:publisher_name).of_type(:text) }
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
  it { is_expected.to have_db_column(:open_access_url).of_type(:text) }
  it { is_expected.to have_db_column(:user_submitted_open_access_url).of_type(:text) }
  it { is_expected.to have_db_column(:scholarsphere_open_access_url).of_type(:text) }
  it { is_expected.to have_db_column(:duplicate_publication_group_id).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_by_user_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:visible).of_type(:boolean).with_options(default: true) }
  it { is_expected.to have_db_column(:open_access_button_last_checked_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:journal_id).of_type(:integer) }
  it { is_expected.to have_db_column(:exported_to_activity_insight).of_type(:boolean) }

  it { is_expected.to have_db_foreign_key(:duplicate_publication_group_id) }
  it { is_expected.to have_db_foreign_key(:journal_id) }

  it { is_expected.to have_db_index(:duplicate_publication_group_id) }
  it { is_expected.to have_db_index(:journal_id) }
  it { is_expected.to have_db_index(:volume) }
  it { is_expected.to have_db_index(:issue) }
  it { is_expected.to have_db_index(:doi) }
  it { is_expected.to have_db_index(:published_on) }
end


describe Publication, type: :model do
  it_behaves_like "an application record"

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:publication_type) }
    it { is_expected.to validate_presence_of(:status) }

    it { is_expected.to validate_inclusion_of(:publication_type).in_array(Publication.publication_types) }
    it { is_expected.to validate_inclusion_of(:status).in_array(Publication.statuses) }

    describe "validating DOI format" do
      let(:pub) { build :publication, doi: doi }

      context "when given a nil DOI" do
        let(:doi) { nil }
        it "passes validation" do
          expect(pub.valid?).to eq true
        end
      end
      context "when given an empty DOI" do
        let(:doi) { "" }
        it "passes validation" do
          expect(pub.valid?).to eq true
        end
      end
      context "when given a DOI with valid format" do
        let(:doi) { "https://doi.org/10.0000/valid-doi" }
        it "passes validation" do
          expect(pub.valid?).to eq true
        end
      end
      context "when given a blank DOI" do
        let(:doi) { " " }
        it "fails validation" do
          expect(pub.valid?).to eq false
        end
        it "sets an error on the doi field" do
          pub.valid?
          expect(pub.errors[:doi].include?(I18n.t('models.publication.validation_errors.doi_format'))).to eq true
        end
      end
      context "when given a DOI that is not a full URL" do
        let(:doi) { "10.0000/valid-doi" }
        it "fails validation" do
          expect(pub.valid?).to eq false
        end
        it "sets an error on the doi field" do
          pub.valid?
          expect(pub.errors[:doi].include?(I18n.t('models.publication.validation_errors.doi_format'))).to eq true
        end
      end
      context "when given an otherwise valid DOI that has extra whitespace" do
        let(:doi) { "\thttps://doi.org/10.0000/valid-doi" }
        it "fails validation" do
          expect(pub.valid?).to eq false
        end
        it "sets an error on the doi field" do
          pub.valid?
          expect(pub.errors[:doi].include?(I18n.t('models.publication.validation_errors.doi_format'))).to eq true
        end
      end
      context "when given an otherwise valid DOI that contains an illegal character" do
        let(:doi) { "https://doi.org/10.0000/valid\u2013doi" }
        it "fails validation" do
          expect(pub.valid?).to eq false
        end
        it "sets an error on the doi field" do
          pub.valid?
          expect(pub.errors[:doi].include?(I18n.t('models.publication.validation_errors.doi_format'))).to eq true
        end
      end
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:authorships).inverse_of(:publication) }
    it { is_expected.to have_many(:users).through(:authorships) }
    it { is_expected.to have_many(:contributor_names).dependent(:destroy).inverse_of(:publication) }
    it { is_expected.to have_many(:imports).class_name(:PublicationImport) }
    it { is_expected.to have_many(:taggings).inverse_of(:publication).class_name(:PublicationTagging) }
    it { is_expected.to have_many(:tags).through(:taggings) }
    it { is_expected.to have_many(:organizations).through(:users) }
    it { is_expected.to have_many(:user_organization_memberships).through(:users) }
    it { is_expected.to have_many(:research_funds) }
    it { is_expected.to have_many(:grants).through(:research_funds) }
    it { is_expected.to have_many(:waivers).through(:authorships) }
    it { is_expected.to have_many(:non_duplicate_group_memberships).class_name(:NonDuplicatePublicationGroupMembership).inverse_of(:publication) }
    it { is_expected.to have_many(:non_duplicate_groups).class_name(:NonDuplicatePublicationGroup).through(:non_duplicate_group_memberships) }
    it { is_expected.to have_many(:non_duplicates).through(:non_duplicate_groups).class_name(:Publication).source(:publications) }

    it { is_expected.to belong_to(:duplicate_group).class_name(:DuplicatePublicationGroup).optional.inverse_of(:publications) }
    it { is_expected.to belong_to(:journal).optional.inverse_of(:publications) }

    it { is_expected.to have_one(:publisher).through(:journal) }
  end

  it { is_expected.to accept_nested_attributes_for(:authorships).allow_destroy(true) }
  it { is_expected.to accept_nested_attributes_for(:contributor_names).allow_destroy(true) }
  it { is_expected.to accept_nested_attributes_for(:taggings).allow_destroy(true) }

  describe "deleting a publication with authorships" do
    let(:p) { create :publication }
    let!(:a) { create :authorship, publication: p}
    it "also deletes the publication's authorships" do
      p.destroy
      expect { a.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "deleting a publication with contributor names" do
    let(:p) { create :publication }
    let!(:c) { create :contributor_name, publication: p}
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

  describe "deleting a publication with research funds" do
    let(:p) { create :publication }
    let!(:rf) { create :research_fund, publication: p}
    it "also deletes the publication's research funds" do
      p.destroy
      expect { rf.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "deleting a publication with non-duplicate group memberships" do
    let(:p) { create :publication }
    let!(:ndpgm) { create :non_duplicate_publication_group_membership, publication: p }
    it "also deletes the publication's non-duplicate publication group memberships" do
      p.destroy
      expect { ndpgm.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "deleting a publication with imports" do
    let(:p) { create :publication }
    let!(:pi) { create :publication_import, publication: p}
    it "also deletes the publication's imports" do
      p.destroy
      expect { pi.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '.publication_types' do
    it "returns the list of valid publication types" do
      expect(Publication.publication_types).to eq ["Academic Journal Article", "In-house Journal Article",
                                                   "Professional Journal Article", "Trade Journal Article",
                                                   "Journal Article", "Review Article", "Abstract", "Blog", "Book",
                                                   "Chapter", "Book/Film/Article Review", "Conference Proceeding",
                                                   "Encyclopedia/Dictionary Entry", "Extension Publication",
                                                   "Magazine/Trade Publication", "Manuscript", "Newsletter",
                                                   "Newspaper Article", "Comment/Debate", "Commissioned Report",
                                                   "Digital or Visual Product", "Editorial", "Foreword/Postscript",
                                                   "Letter", "Paper", "Patent", "Poster", "Scholarly Edition",
                                                   "Short Survey", "Working Paper", "Other"]
    end
  end

  describe '.statuses' do
    it "returns a list of valid statuses" do
      expect(Publication.statuses).to eq ['Published', 'In Press']
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

  describe '.subject_to_open_access_policy' do
    let!(:pub1) { create :publication, published_on: Date.new(2020, 6, 30) }
    let!(:pub2) { create :publication, published_on: Date.new(2020, 7, 1) }
    let!(:pub3) { create :publication, published_on: Date.new(2020, 7, 2) }
    let!(:pub4) { create :publication, published_on: Date.new(2020, 7, 2), publication_type: 'Chapter' }
    let!(:pub5) { create :publication, published_on: Date.new(2020, 7, 2), status: 'In Press' }
    it "returns publications that were published after Penn State's open access policy went into effect and have a status of 'Published'" do
      expect(Publication.subject_to_open_access_policy).to match_array [pub2, pub3]
    end
  end

  describe '.open_access' do
    let!(:pub1) { create :publication,
                         open_access_url: nil,
                         user_submitted_open_access_url: nil,
                         scholarsphere_open_access_url: nil }
    let!(:pub2) { create :publication,
                         open_access_url: 'url',
                         user_submitted_open_access_url: nil,
                         scholarsphere_open_access_url: nil }
    let!(:pub3) { create :publication,
                         open_access_url: nil,
                         user_submitted_open_access_url: 'url',
                         scholarsphere_open_access_url: nil}
    let!(:pub4) { create :publication,
                         open_access_url: nil,
                         user_submitted_open_access_url: nil,
                         scholarsphere_open_access_url: 'url'
                         }
    let!(:pub5) { create :publication,
                         open_access_url: 'url',
                         user_submitted_open_access_url: 'url',
                         scholarsphere_open_access_url: 'url'
                         }
    let!(:pub6) { create :publication,
                         open_access_url: '',
                         user_submitted_open_access_url: nil,
                         scholarsphere_open_access_url: nil }
    let!(:pub6) { create :publication,
                         open_access_url: nil,
                         user_submitted_open_access_url: '',
                         scholarsphere_open_access_url: nil }
    let!(:pub6) { create :publication,
                         open_access_url: nil,
                         user_submitted_open_access_url: nil,
                         scholarsphere_open_access_url: '' }
                         
    it "returns publications that have an open access URL" do
      expect(Publication.open_access).to match_array [pub2, pub3, pub4, pub5]
    end
  end

  describe '.find_by_wos_pub' do
    let(:wos_pub) { double 'WoS publication',
                           doi: doi,
                           title: title,
                           publication_date: date }
    let!(:pub1) { create :publication,
                         doi: nil,
                         title: "Another Publication",
                         published_on: Date.new(2000, 1, 1) }
    let!(:pub2) { create :publication,
                         doi: "https://doi.org/10.000/DOI123",
                         title: "Some Text Before The Title Some Text After",
                         published_on: Date.new(2000, 1, 1) }
    let!(:pub3) { create :publication,
                         doi: "https://doi.org/10.000/DOI456",
                         title: "Some Text Before The Title Some Text After",
                         published_on: Date.new(2001, 2, 2) }
    let!(:pub4) { create :publication,
                         doi: "https://doi.org/10.000/DOI111",
                         title: "Another Publication",
                         published_on: Date.new(2001, 2, 2) }
    let!(:pub5) { create :publication,
                         doi: "https://doi.org/10.000/DOI222",
                         title: "Another Publication",
                         published_on: Date.new(2000, 1, 1) }

    context "when given publication data with no DOI" do
      let(:doi) { nil }
      context "when given data with a title that is a case-insensitive, partial match for an existing publication" do
        let(:title) { "THE TITLE" }
        context "when given data with no publication date" do
          let(:date) { nil }
          it "returns an empty array" do
            expect(Publication.find_by_wos_pub(wos_pub)).to eq []
          end
        end
        context "when given data with a publication year that matches an existing publication" do
          let(:date) { Date.new(2000, 1, 1) }
          it "returns the publication that matches by title and date" do
            expect(Publication.find_by_wos_pub(wos_pub)).to eq [pub2]
          end
        end
        context "when given data with a publication year that does not match an existing publication" do
          let(:date) { Date.new(2010, 1, 1) }
          it "returns an empty array" do
            expect(Publication.find_by_wos_pub(wos_pub)).to eq []
          end
        end
      end
      context "when given data with a title that is not a case-insensitive partial match for an existing publication" do
        let(:title) { "Other Title" }
        context "when given data with no publication date" do
          let(:date) { nil }
          it "returns an empty array" do
            expect(Publication.find_by_wos_pub(wos_pub)).to eq []
          end
        end
        context "when given data with a publication year that matches an existing publication" do
          let(:date) { Date.new(2000, 1, 1) }
          it "returns an empty array" do
            expect(Publication.find_by_wos_pub(wos_pub)).to eq []
          end
        end
        context "when given data with a publication year that does not match an existing publication" do
          let(:date) { Date.new(2010, 1, 1) }
          it "returns an empty array" do
            expect(Publication.find_by_wos_pub(wos_pub)).to eq []
          end
        end
      end
    end
    context "when given publication data with a DOI that matches an existing publication" do
      let(:doi) { "https://doi.org/10.000/DOI456" }
      context "when given data with a title that is a case-insensitive, partial match for an existing publication" do
        let(:title) { "THE TITLE" }
        context "when given data with no publication date" do
          let(:date) { nil }
          it "returns the publication with the matching DOI" do
            expect(Publication.find_by_wos_pub(wos_pub)).to eq [pub3]
          end
        end
        context "when given data with a publication year that matches an existing publication" do
          let(:date) { Date.new(2000, 1, 1) }
          it "returns the publication with the matching DOI" do
            expect(Publication.find_by_wos_pub(wos_pub)).to eq [pub3]
          end
        end
        context "when given data with a publication year that does not match an existing publication" do
          let(:date) { Date.new(2010, 1, 1) }
          it "returns the publication with the matching DOI" do
            expect(Publication.find_by_wos_pub(wos_pub)).to eq [pub3]
          end
        end
      end
      context "when given data with a title that is not a case-insensitive partial match for an existing publication" do
        let(:title) { "Other Title" }
        context "when given data with no publication date" do
          let(:date) { nil }
          it "returns the publication with the matching DOI" do
            expect(Publication.find_by_wos_pub(wos_pub)).to eq [pub3]
          end
        end
        context "when given data with a publication year that matches an existing publication" do
          let(:date) { Date.new(2000, 1, 1) }
          it "returns the publication with the matching DOI" do
            expect(Publication.find_by_wos_pub(wos_pub)).to eq [pub3]
          end
        end
        context "when given data with a publication year that does not match an existing publication" do
          let(:date) { Date.new(2010, 1, 1) }
          it "returns the publication with the matching DOI" do
            expect(Publication.find_by_wos_pub(wos_pub)).to eq [pub3]
          end
        end
      end
    end
    context "when given publication data with a DOI that doesn't match an existing publication" do
      let(:doi) { "DOI789" }
      context "when given data with a title that is a case-insensitive, partial match for an existing publication" do
        let(:title) { "THE TITLE" }
        context "when given data with no publication date" do
          let(:date) { nil }
          it "returns an empty array" do
            expect(Publication.find_by_wos_pub(wos_pub)).to eq []
          end
        end
        context "when given data with a publication year that matches an existing publication" do
          let(:date) { Date.new(2000, 1, 1) }
          it "returns the publication that matches by title and date" do
            expect(Publication.find_by_wos_pub(wos_pub)).to eq [pub2]
          end
        end
        context "when given data with a publication year that does not match an existing publication" do
          let(:date) { Date.new(2010, 1, 1) }
          it "returns an empty array" do
            expect(Publication.find_by_wos_pub(wos_pub)).to eq []
          end
        end
      end
      context "when given data with a title that is not a case-insensitive partial match for an existing publication" do
        let(:title) { "Other Title" }
        context "when given data with no publication date" do
          let(:date) { nil }
          it "returns an empty array" do
            expect(Publication.find_by_wos_pub(wos_pub)).to eq []
          end
        end
        context "when given data with a publication year that matches an existing publication" do
          let(:date) { Date.new(2000, 1, 1) }
          it "returns an empty array" do
            expect(Publication.find_by_wos_pub(wos_pub)).to eq []
          end
        end
        context "when given data with a publication year that does not match an existing publication" do
          let(:date) { Date.new(2010, 1, 1) }
          it "returns an empty array" do
            expect(Publication.find_by_wos_pub(wos_pub)).to eq []
          end
        end
      end
    end
  end

  describe '.journal_article' do
    let(:pub1) { FactoryBot.create :publication, publication_type: 'Journal Article' }
    let(:pub2) { FactoryBot.create :publication, publication_type: 'Academic Journal Article' }
    let(:pub3) { FactoryBot.create :publication, publication_type: 'In-house Journal Article' }
    let(:pub4) { FactoryBot.create :publication, publication_type: 'Book' }
    let(:pub5) { FactoryBot.create :publication, publication_type: 'Letter' }
    let(:pub6) { FactoryBot.create :publication, publication_type: 'Conference Proceeding' }
    it 'returns publications that are journal articles' do
      expect(Publication.journal_article).to match_array [pub1, pub2, pub3]
    end
  end

  describe '.non_journal_article' do
    let(:pub1) { FactoryBot.create :publication, publication_type: 'Journal Article' }
    let(:pub2) { FactoryBot.create :publication, publication_type: 'Academic Journal Article' }
    let(:pub3) { FactoryBot.create :publication, publication_type: 'In-house Journal Article' }
    let(:pub4) { FactoryBot.create :publication, publication_type: 'Book' }
    let(:pub5) { FactoryBot.create :publication, publication_type: 'Letter' }
    let(:pub6) { FactoryBot.create :publication, publication_type: 'Conference Proceeding' }
    it 'returns publications that are not journal articles' do
      expect(Publication.non_journal_article).to match_array [pub4, pub5, pub6]
    end
  end

  describe '#confirmed_authorships' do
    let!(:pub) { create :publication }
    let!(:a1) { create :authorship, publication: pub, confirmed: false }
    let!(:a2) { create :authorship, publication: pub, confirmed: true }
    it "returns only the publication's authorships that are confirmed" do
      expect(pub.confirmed_authorships).to eq [a2]
    end
  end

  describe '#contributors' do
    let(:pub) { create :publication }
    let!(:c1) { create :contributor_name, position: 2, publication: pub }
    let!(:c2) { create :contributor_name, position: 3, publication: pub }
    let!(:c3) { create :contributor_name, position: 1, publication: pub }

    it "returns the publication's contributors in order by position" do
      expect(pub.contributor_names).to eq [c3, c1, c2]
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
    let(:pub) { Publication.new }
    let(:policy) { double 'preferred journal info policy', publisher_name: pn, journal_title: jt }
    before { allow(PreferredJournalInfoPolicy).to receive(:new).with(pub).and_return policy }

    context "when the publication has a journal title" do
      let(:jt) { "The Journal" }
      context "when the publication has a publisher" do
        let(:pn) { "The Publisher" }

        it "returns the journal title" do
          expect(pub.published_by).to eq "The Journal"
        end
      end

      context "when the publication does not have a publisher" do
        let(:pn) { nil }

        it "returns the journal title" do
          expect(pub.published_by).to eq "The Journal"
        end
      end
    end

    context "when the publication does not have a journal title" do
      let(:jt) { nil }
      context "when the publication has a publisher" do
        let(:pn) { "The Publisher" }

        it "returns the publisher" do
          expect(pub.published_by).to eq "The Publisher"
        end
      end

      context "when the publication does not have a publisher" do
        let(:pn) { nil }

        it "returns nil" do
          expect(pub.published_by).to be_nil
        end
      end
    end
  end

  describe '#doi_url_path' do
    let(:pub) { Publication.new(doi: doi) }

    context "when the publication's DOI is nil" do
      let(:doi) { nil }
      it "returns nil" do
        expect(pub.doi_url_path).to eq nil
      end
    end

    context "when the publication's DOI is a full URL" do
      let(:doi) { "https://doi.org/10.1016/S0148-2963(01)00209-0" }
      it "returns only the path part of the URL" do
        expect(pub.doi_url_path).to eq "10.1016/S0148-2963(01)00209-0"
      end
    end
  end

  describe '#preferred_open_access_url' do
    let(:pub) { Publication.new }
    let(:policy) { double 'preferred open access policy', url: 'preferred_url' }

    before { allow(PreferredOpenAccessPolicy).to receive(:new).with(pub).and_return policy }

    it "returns the preferred URL" do
      expect(pub.preferred_open_access_url).to eq 'preferred_url'
    end
  end

  describe "#scholarsphere_upload_pending?" do
    let(:pub) { create :publication }
    let(:auth) { create :authorship, publication: pub }

    context "when the publication has no authorships with a pending ScholarSphere deposit" do
      it "returns false" do
        expect(pub.scholarsphere_upload_pending?).to eq false
      end
    end
    
    context "when the publication has an authorship with a pending ScholarSphere deposit" do
      before do
        create :scholarsphere_work_deposit, authorship: auth, status: 'Pending'
      end

      it "returns true" do
        expect(pub.scholarsphere_upload_pending?).to eq true
      end
    end

    context "when the publication has an authorship with a non-pending ScholarSphere deposit" do
      before do
        create :scholarsphere_work_deposit, authorship: auth, status: 'Success'
      end

      it "returns false" do
        expect(pub.scholarsphere_upload_pending?).to eq false
      end
    end
  end

  describe "#scholarsphere_upload_failed?" do
    let(:pub) { create :publication }
    let(:auth) { create :authorship, publication: pub }

    context "when the publication has no authorships with a failed ScholarSphere deposit" do
      it "returns false" do
        expect(pub.scholarsphere_upload_failed?).to eq false
      end
    end
    
    context "when the publication has an authorship with a failed ScholarSphere deposit" do
      before do
        create :scholarsphere_work_deposit, authorship: auth, status: 'Failed'
      end

      it "returns true" do
        expect(pub.scholarsphere_upload_failed?).to eq true
      end
    end

    context "when the publication has an authorship with a non-failed ScholarSphere deposit" do
      before do
        create :scholarsphere_work_deposit, authorship: auth, status: 'Success'
      end

      it "returns false" do
        expect(pub.scholarsphere_upload_failed?).to eq false
      end
    end
  end

  describe '#open_access_waived?' do
    let(:pub) { create :publication }
    let!(:auth1) { create :authorship, publication: pub }
    let!(:auth2) { create :authorship, publication: pub }

    context "when none of the publication's authorships have a waiver" do
      it "returns false" do
        expect(pub.open_access_waived?).to eq false
      end
    end

    context "when one of the publication's authorships has a waiver" do
      before { create :internal_publication_waiver, authorship: auth2 }
      it "returns true" do
        expect(pub.open_access_waived?).to eq true
      end
    end
  end

  describe "#no_open_access_information?" do
    let!(:pub) { create :publication }
    let!(:auth1) { create :authorship, publication: pub }
    let!(:auth2) { create :authorship, publication: pub }
    let(:policy) { double 'open access policy', url: url }
    let(:url) { nil }

    before { allow(PreferredOpenAccessPolicy).to receive(:new).with(pub).and_return policy }
    context "when none of the publication's authorships have a waiver" do
      context "when the publication does not have an authorship with a pending ScholarSphere deposit" do
        context "when there is not a preferred open access URL for the publication" do
          it "returns true" do
            expect(pub.no_open_access_information?).to eq true
          end
        end
        context "when there is a preferred open access URL for the publication" do
          let(:url) { 'a_url' }

          it "returns false" do
            expect(pub.no_open_access_information?).to eq false
          end
        end
      end
      
      context "when the publication has an authorship with a pending ScholarSphere deposit" do
        before { create :scholarsphere_work_deposit, authorship: auth1, status: 'Pending' }
        context "when there is not a preferred open access URL for the publication" do
          it "returns false" do
            expect(pub.no_open_access_information?).to eq false
          end
        end
        context "when there is a preferred open access URL for the publication" do
          let(:url) { 'a_url' }

          it "returns false" do
            expect(pub.no_open_access_information?).to eq false
          end
        end
      end

      context "when the publication has an authorship with a non-pending ScholarSphere deposit" do
        before { create :scholarsphere_work_deposit, authorship: auth1, status: 'Success' }
        context "when there is not a preferred open access URL for the publication" do
          it "returns true" do
            expect(pub.no_open_access_information?).to eq true
          end
        end
        context "when there is a preferred open access URL for the publication" do
          let(:url) { 'a_url' }

          it "returns false" do
            expect(pub.no_open_access_information?).to eq false
          end
        end
      end
    end

    context "when one of the publication's authorships has a waiver" do
      before { create :internal_publication_waiver, authorship: auth2 }

      context "when the publication does not have an authorship with a pending ScholarSphere deposit" do
        context "when there is not a preferred open access URL for the publication" do
          it "returns false" do
            expect(pub.no_open_access_information?).to eq false
          end
        end
        context "when there is a preferred open access URL for the publication" do
          let(:url) { 'a_url' }

          it "returns false" do
            expect(pub.no_open_access_information?).to eq false
          end
        end
      end
      
      context "when the publication has an authorship with a pending ScholarSphere deposit" do
        before { create :scholarsphere_work_deposit, authorship: auth1, status: 'Pending' }
        context "when there is not a preferred open access URL for the publication" do
          it "returns false" do
            expect(pub.no_open_access_information?).to eq false
          end
        end
        context "when there is a preferred open access URL for the publication" do
          let(:url) { 'a_url' }

          it "returns false" do
            expect(pub.no_open_access_information?).to eq false
          end
        end
      end

      context "when the publication has an authorship with a non-pending ScholarSphere deposit" do
        before { create :scholarsphere_work_deposit, authorship: auth1, status: 'Success' }
        context "when there is not a preferred open access URL for the publication" do
          it "returns false" do
            expect(pub.no_open_access_information?).to eq false
          end
        end
        context "when there is a preferred open access URL for the publication" do
          let(:url) { 'a_url' }

          it "returns false" do
            expect(pub.no_open_access_information?).to eq false
          end
        end
      end
    end
  end

  describe "#has_open_access_information?" do
    let!(:pub) { create :publication }
    let!(:auth1) { create :authorship, publication: pub }
    let!(:auth2) { create :authorship, publication: pub }
    let(:policy) { double 'open access policy', url: url }
    let(:url) { nil }

    before { allow(PreferredOpenAccessPolicy).to receive(:new).with(pub).and_return policy }
    context "when none of the publication's authorships have a waiver" do
      context "when the publication has no authorships that have been uploaded to ScholarSphere" do
        context "when there is not a preferred open access URL for the publication" do
          it "returns false" do
            expect(pub.has_open_access_information?).to eq false
          end
        end
        context "when there is a preferred open access URL for the publication" do
          let(:url) { 'a_url' }

          it "returns true" do
            expect(pub.has_open_access_information?).to eq true
          end
        end
      end
      
      context "when the publication has an authorship with a pending ScholarSphere deposit" do
        before { create :scholarsphere_work_deposit, authorship: auth1, status: 'Pending' }
        context "when there is not a preferred open access URL for the publication" do
          it "returns true" do
            expect(pub.has_open_access_information?).to eq true
          end
        end
        context "when there is a preferred open access URL for the publication" do
          let(:url) { 'a_url' }

          it "returns true" do
            expect(pub.has_open_access_information?).to eq true
          end
        end
      end

      context "when the publication has an authorship with a non-pending ScholarSphere deposit" do
        before { create :scholarsphere_work_deposit, authorship: auth1, status: 'Success' }
        context "when there is not a preferred open access URL for the publication" do
          it "returns false" do
            expect(pub.has_open_access_information?).to eq false
          end
        end
        context "when there is a preferred open access URL for the publication" do
          let(:url) { 'a_url' }

          it "returns true" do
            expect(pub.has_open_access_information?).to eq true
          end
        end
      end
    end

    context "when one of the publication's authorships has a waiver" do
      before { create :internal_publication_waiver, authorship: auth2 }

      context "when the publication has no authorships that have been uploaded to ScholarSphere" do
        context "when there is not a preferred open access URL for the publication" do
          it "returns true" do
            expect(pub.has_open_access_information?).to eq true
          end
        end
        context "when there is a preferred open access URL for the publication" do
          let(:url) { 'a_url' }

          it "returns true" do
            expect(pub.has_open_access_information?).to eq true
          end
        end
      end
      
      context "when the publication has an authorship with a pending ScholarSphere deposit" do
        before { create :scholarsphere_work_deposit, authorship: auth1, status: 'Pending' }
        context "when there is not a preferred open access URL for the publication" do
          it "returns true" do
            expect(pub.has_open_access_information?).to eq true
          end
        end
        context "when there is a preferred open access URL for the publication" do
          let(:url) { 'a_url' }

          it "returns true" do
            expect(pub.has_open_access_information?).to eq true
          end
        end
      end

      context "when the publication has an authorship with a non-pending ScholarSphere deposit" do
        before { create :scholarsphere_work_deposit, authorship: auth1, status: 'Success' }
        context "when there is not a preferred open access URL for the publication" do
          it "returns true" do
            expect(pub.has_open_access_information?).to eq true
          end
        end
        context "when there is a preferred open access URL for the publication" do
          let(:url) { 'a_url' }

          it "returns true" do
            expect(pub.has_open_access_information?).to eq true
          end
        end
      end
    end
  end

  describe '#merge!' do
    let!(:user1) { create :user }
    let!(:user2) { create :user }
    let!(:user3) { create :user }

    let!(:pub1) { create :publication, updated_by_user_at: nil, visible: visibility }
    let!(:pub2) { create :publication }
    let!(:pub3) { create :publication }
    let!(:pub4) { create :publication }

    let!(:pub1_import1) { create :publication_import, publication: pub1 }
    let!(:pub2_import1) { create :publication_import, publication: pub2 }
    let!(:pub2_import2) { create :publication_import, publication: pub2 }
    let!(:pub3_import1) { create :publication_import, publication: pub3 }

    let(:waiver1) { build :internal_publication_waiver }
    let(:waiver2) { build :internal_publication_waiver }

    let(:deposit1) { build :scholarsphere_work_deposit }
    let(:deposit2) { build :scholarsphere_work_deposit }
    let(:deposit3) { build :scholarsphere_work_deposit }

    let(:visibility) { false }

    before do
      create :authorship,
             publication: pub1,
             user: user1,
             author_number: 1,
             confirmed: false,
             role: nil,
             orcid_resource_identifier: 'older-orcid-identifier',
             updated_by_owner_at: Time.new(2020, 1, 1, 0, 0, 0),
             visible_in_profile: true,
             position_in_profile: nil,
             scholarsphere_work_deposits: [deposit3]

      create :authorship,
             publication: pub2,
             user: user1,
             author_number: 1,
             confirmed: true,
             role: 'author',
             orcid_resource_identifier: 'newer-orcid-identifier',
             updated_by_owner_at: Time.new(2021, 1, 1, 0, 0, 0),
             open_access_notification_sent_at: Time.new(2000, 1, 1, 0, 0, 0),
             waiver: waiver1,
             visible_in_profile: false,
             position_in_profile: 2,
             scholarsphere_work_deposits: [deposit1, deposit2]
      create :authorship,
             publication: pub2,
             user: user2,
             author_number: 2,
             confirmed: false,
             role: 'co-author',
             orcid_resource_identifier: 'newer-orcid-identifier-2',
             updated_by_owner_at: Time.new(2021, 1, 1, 0, 0, 0)

      create :authorship,
             publication: pub3,
             user: user3,
             author_number: 3,
             confirmed: true,
             role: nil,
             orcid_resource_identifier: nil,
             updated_by_owner_at: Time.new(2020, 1, 1, 0, 0, 0),
             open_access_notification_sent_at: Time.new(2000, 1, 1, 0, 0, 0)

      create :authorship,
             publication: pub4,
             user: user1,
             author_number: 1,
             confirmed: false,
             role: 'other author',
             orcid_resource_identifier: nil,
             updated_by_owner_at: Time.new(2019, 1, 1, 0, 0, 0),
             waiver: waiver2,
             position_in_profile: 1
      create :authorship,
             publication: pub4,
             user: user2,
             author_number: 2,
             confirmed: false,
             role: nil,
             orcid_resource_identifier: 'older-orcid-identifier-2',
             updated_by_owner_at: Time.new(2019, 1, 1, 0, 0, 0)
      create :authorship,
             publication: pub4,
             user: user3,
             author_number: 3,
             confirmed: true,
             role: nil,
             orcid_resource_identifier: 'orcid-identifier-3',
             updated_by_owner_at: Time.new(2019, 1, 1, 0, 0, 0),
             open_access_notification_sent_at: Time.new(2010, 1, 1, 0, 0, 0)

    end
  
    it "reassigns all of the imports from the given publications to the publication" do
      pub1.merge!([pub2, pub3, pub4])

      expect(pub1.reload.imports).to match_array [pub1_import1,
                                                  pub2_import1,
                                                  pub2_import2,
                                                  pub3_import1]
    end

    it "transfers all of the authorships from all of the given publications to the publication" do
      pub1.merge!([pub2, pub3, pub4])

      expect(pub1.authorships.count).to eq 3

      expect(pub1.authorships.find_by(user: user1, author_number: 1)).not_to be_nil
      expect(pub1.authorships.find_by(user: user2, author_number: 2)).not_to be_nil
      expect(pub1.authorships.find_by(user: user3, author_number: 3)).not_to be_nil
    end

    it "transfers authorship confirmation with confirmation presence winning in the event of a conflict" do
      pub1.merge!([pub2, pub3, pub4])

      auth1 = pub1.authorships.find_by(user: user1)
      auth2 = pub1.authorships.find_by(user: user2)
      auth3 = pub1.authorships.find_by(user: user3)

      expect(auth1.confirmed).to eq true
      expect(auth2.confirmed).to eq false
      expect(auth3.confirmed).to eq true
    end

    it "transfers authorship roles" do
      pub1.merge!([pub2, pub3, pub4])

      auth1 = pub1.authorships.find_by(user: user1)
      auth2 = pub1.authorships.find_by(user: user2)
      auth3 = pub1.authorships.find_by(user: user3)

      expect(auth1.role).to eq 'author'
      expect(auth2.role).to eq 'co-author'
      expect(auth3.role).to eq nil
    end

    it "transfers ORCiD identifiers" do
      pub1.merge!([pub2, pub3, pub4])

      auth1 = pub1.authorships.find_by(user: user1)
      auth2 = pub1.authorships.find_by(user: user2)
      auth3 = pub1.authorships.find_by(user: user3)

      expect(auth1.orcid_resource_identifier).to eq 'newer-orcid-identifier'
      expect(auth2.orcid_resource_identifier).to eq 'newer-orcid-identifier-2'
      expect(auth3.orcid_resource_identifier).to eq 'orcid-identifier-3'
    end

    it "transfers open access notification timestamps" do
      pub1.merge!([pub2, pub3, pub4])

      auth1 = pub1.authorships.find_by(user: user1)
      auth2 = pub1.authorships.find_by(user: user2)
      auth3 = pub1.authorships.find_by(user: user3)

      expect(auth1.open_access_notification_sent_at).to eq Time.new(2000, 1, 1, 0, 0, 0)
      expect(auth2.open_access_notification_sent_at).to eq nil
      expect(auth3.open_access_notification_sent_at).to eq Time.new(2010, 1, 1, 0, 0, 0)
    end

    it "transfers owner modification timestamps" do
      pub1.merge!([pub2, pub3, pub4])

      auth1 = pub1.authorships.find_by(user: user1)
      auth2 = pub1.authorships.find_by(user: user2)
      auth3 = pub1.authorships.find_by(user: user3)

      expect(auth1.updated_by_owner_at).to eq Time.new(2021, 1, 1, 0, 0, 0)
      expect(auth2.updated_by_owner_at).to eq Time.new(2021, 1, 1, 0, 0, 0)
      expect(auth3.updated_by_owner_at).to eq Time.new(2020, 1, 1, 0, 0, 0)
    end

    it "transfers waivers" do
      pub1.merge!([pub2, pub3, pub4])

      auth1 = pub1.authorships.find_by(user: user1)
      auth2 = pub1.authorships.find_by(user: user2)
      auth3 = pub1.authorships.find_by(user: user3)

      expect(auth1.waiver).to eq waiver1
      expect(auth2.waiver).to eq nil
      expect(auth3.waiver).to eq nil
    end

    it "transfers ScholarSphere deposits" do
      pub1.merge!([pub2, pub3, pub4])

      auth1 = pub1.authorships.find_by(user: user1)
      auth2 = pub1.authorships.find_by(user: user2)
      auth3 = pub1.authorships.find_by(user: user3)

      expect(auth1.scholarsphere_work_deposits).to match_array [deposit1, deposit2, deposit3]
      expect(auth2.scholarsphere_work_deposits).to eq []
      expect(auth3.scholarsphere_work_deposits).to eq []
    end

    it "transfers visibility" do
      pub1.merge!([pub2, pub3, pub4])

      auth1 = pub1.authorships.find_by(user: user1)
      auth2 = pub1.authorships.find_by(user: user2)
      auth3 = pub1.authorships.find_by(user: user3)

      expect(auth1.visible_in_profile).to eq false
      expect(auth2.visible_in_profile).to eq true
      expect(auth3.visible_in_profile).to eq true
    end

    it "transfers position" do
      pub1.merge!([pub2, pub3, pub4])

      auth1 = pub1.authorships.find_by(user: user1)
      auth2 = pub1.authorships.find_by(user: user2)
      auth3 = pub1.authorships.find_by(user: user3)

      expect(auth1.position_in_profile).to eq 2
      expect(auth2.position_in_profile).to eq nil
      expect(auth3.position_in_profile).to eq nil
    end

    it "deletes the given publications" do
      pub1.merge!([pub2, pub3, pub4])

      expect { pub2.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { pub3.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { pub4.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it "updates the modification timestamp on the publication" do
      pub1.merge!([pub2, pub3, pub4])

      expect(pub1.reload.updated_by_user_at).to be_within(1.minute).of(Time.current)
    end


    context "when the publication is not visible" do
      it "makes the publication visible" do
        pub1.merge!([pub2, pub3, pub4])

        expect(pub1.reload.visible).to eq true
      end
    end

    context "when the publication is visible" do
      let(:visibility) { true }
      it "leaves the publication visible" do
        pub1.merge!([pub2, pub3, pub4])

        expect(pub1.reload.visible).to eq true
      end
    end

    context "when the given publications include the publication" do
      it "reassigns all of the imports from the given publications to the publication" do
        pub1.merge!([pub1, pub2, pub3, pub4])

        expect(pub1.reload.imports).to match_array [pub1_import1,
                                                    pub2_import1,
                                                    pub2_import2,
                                                    pub3_import1]
      end

      it "deletes the given publications except for the publication" do
        pub1.merge!([pub1, pub2, pub3, pub4])

        expect { pub2.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { pub3.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { pub4.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it "updates the modification timestamp on the publication" do
        pub1.merge!([pub1, pub2, pub3, pub4])

        expect(pub1.reload.updated_by_user_at).to be_within(1.minute).of(Time.current)
      end

      context "when the publication is not visible" do
        it "makes the publication visible" do
          pub1.merge!([pub2, pub3, pub4])

          expect(pub1.reload.visible).to eq true
        end
      end

      context "when the publication is visible" do
        let(:visibility) { true }
        it "leaves the publication visible" do
          pub1.merge!([pub2, pub3, pub4])

          expect(pub1.reload.visible).to eq true
        end
      end
    end

    context "when an error is raised" do
      before { allow(pub3).to receive(:destroy).and_raise RuntimeError }

      it "does not reassign any imports" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue RuntimeError; end

        expect(pub1.reload.imports).to match_array [pub1_import1]
        expect(pub2.reload.imports).to match_array [pub2_import1, pub2_import2]
        expect(pub3.reload.imports).to match_array [pub3_import1]
        expect(pub4.reload.imports).to eq []
      end

      it "does not delete any publications" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue RuntimeError; end

        expect(pub2.reload).to eq pub2
        expect(pub3.reload).to eq pub3
        expect(pub4.reload).to eq pub4
      end

      it "does not update the modification timestamp on the publication" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue RuntimeError; end
        
        expect(pub1.reload.updated_by_user_at).to be_nil
      end

      it "does not transfer any authorships" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue RuntimeError; end

        expect(pub1.authorships.count).to eq 1
        expect(pub1.authorships.find_by(user: user1, author_number: 1)).not_to be_nil
      end

      it "does not transfer any authorship confirmation information" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue RuntimeError; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.confirmed).to eq false
      end

      it "does not transfer any authorship roles" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue RuntimeError; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.role).to be_nil
      end

      it "does not transfer any orcid identifiers" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue RuntimeError; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.orcid_resource_identifier).to eq 'older-orcid-identifier'
      end

      it "does not transfer any open access notification timestamps" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue RuntimeError; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.open_access_notification_sent_at).to eq nil
      end

      it "does not transfer any owner modification timestamps" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue RuntimeError; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.updated_by_owner_at).to eq Time.new(2020, 1, 1, 0, 0, 0)
      end

      it "does not transfer any waivers" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue RuntimeError; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.waiver).to eq nil
      end

      it "does not transfer any ScholarSphere deposits" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue RuntimeError; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.scholarsphere_work_deposits).to eq [deposit3]
      end

      it "does not transfer visibility" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue RuntimeError; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.visible_in_profile).to eq true
      end

      it "does not transfer position" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue RuntimeError; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.position_in_profile).to eq nil
      end

      context "when the publication is not visible" do
        it "does not change the visibility" do
          begin
            pub1.merge!([pub2, pub3, pub4])
          rescue RuntimeError; end

          expect(pub1.reload.visible).to eq false
        end
      end

      context "when the publication is visible" do
        let(:visibility) { true }
        it "does not change the visibility" do
          begin
            pub1.merge!([pub2, pub3, pub4])
          rescue RuntimeError; end

          expect(pub1.reload.visible).to eq true
        end
      end
    end

    context "when one of the given publications is in a non-duplicate group" do
      let!(:ndpg) { create :non_duplicate_publication_group, publications: [pub2] }

      it "reassigns all of the imports from the given publications to the publication" do
        pub1.merge!([pub2, pub3, pub4])

        expect(pub1.reload.imports).to match_array [pub1_import1,
                                                    pub2_import1,
                                                    pub2_import2,
                                                    pub3_import1]
      end

      it "deletes the given publications" do
        pub1.merge!([pub2, pub3, pub4])

        expect { pub2.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { pub3.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { pub4.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it "updates the modification timestamp on the publication" do
        pub1.merge!([pub2, pub3, pub4])

        expect(pub1.reload.updated_by_user_at).to be_within(1.minute).of(Time.current)
      end

      it "reassigns the publication to the non-duplicate group" do
        pub1.merge!([pub2, pub3, pub4])

        expect(ndpg.reload.publications).to eq [pub1]
      end

      it "transfers all of the authorships from all of the given publications to the publication" do
        pub1.merge!([pub2, pub3, pub4])

        expect(pub1.authorships.count).to eq 3

        expect(pub1.authorships.find_by(user: user1, author_number: 1)).not_to be_nil
        expect(pub1.authorships.find_by(user: user2, author_number: 2)).not_to be_nil
        expect(pub1.authorships.find_by(user: user3, author_number: 3)).not_to be_nil
      end

      it "transfers authorship confirmation with confirmation presence winning in the event of a conflict" do
        pub1.merge!([pub2, pub3, pub4])

        auth1 = pub1.authorships.find_by(user: user1)
        auth2 = pub1.authorships.find_by(user: user2)
        auth3 = pub1.authorships.find_by(user: user3)

        expect(auth1.confirmed).to eq true
        expect(auth2.confirmed).to eq false
        expect(auth3.confirmed).to eq true
      end

      it "transfers authorship roles" do
        pub1.merge!([pub2, pub3, pub4])

        auth1 = pub1.authorships.find_by(user: user1)
        auth2 = pub1.authorships.find_by(user: user2)
        auth3 = pub1.authorships.find_by(user: user3)

        expect(auth1.role).to eq 'author'
        expect(auth2.role).to eq 'co-author'
        expect(auth3.role).to eq nil
      end

      it "transfers ORCiD identifiers" do
        pub1.merge!([pub2, pub3, pub4])

        auth1 = pub1.authorships.find_by(user: user1)
        auth2 = pub1.authorships.find_by(user: user2)
        auth3 = pub1.authorships.find_by(user: user3)

        expect(auth1.orcid_resource_identifier).to eq 'newer-orcid-identifier'
        expect(auth2.orcid_resource_identifier).to eq 'newer-orcid-identifier-2'
        expect(auth3.orcid_resource_identifier).to eq 'orcid-identifier-3'
      end

      it "transfers open access notification timestamps" do
        pub1.merge!([pub2, pub3, pub4])

        auth1 = pub1.authorships.find_by(user: user1)
        auth2 = pub1.authorships.find_by(user: user2)
        auth3 = pub1.authorships.find_by(user: user3)

        expect(auth1.open_access_notification_sent_at).to eq Time.new(2000, 1, 1, 0, 0, 0)
        expect(auth2.open_access_notification_sent_at).to eq nil
        expect(auth3.open_access_notification_sent_at).to eq Time.new(2010, 1, 1, 0, 0, 0)
      end

      it "transfers owner modification timestamps" do
        pub1.merge!([pub2, pub3, pub4])

        auth1 = pub1.authorships.find_by(user: user1)
        auth2 = pub1.authorships.find_by(user: user2)
        auth3 = pub1.authorships.find_by(user: user3)

        expect(auth1.updated_by_owner_at).to eq Time.new(2021, 1, 1, 0, 0, 0)
        expect(auth2.updated_by_owner_at).to eq Time.new(2021, 1, 1, 0, 0, 0)
        expect(auth3.updated_by_owner_at).to eq Time.new(2020, 1, 1, 0, 0, 0)
      end

      it "transfers waivers" do
        pub1.merge!([pub2, pub3, pub4])

        auth1 = pub1.authorships.find_by(user: user1)
        auth2 = pub1.authorships.find_by(user: user2)
        auth3 = pub1.authorships.find_by(user: user3)

        expect(auth1.waiver).to eq waiver1
        expect(auth2.waiver).to eq nil
        expect(auth3.waiver).to eq nil
      end

      it "transfers ScholarSphere deposits" do
        pub1.merge!([pub2, pub3, pub4])

        auth1 = pub1.authorships.find_by(user: user1)
        auth2 = pub1.authorships.find_by(user: user2)
        auth3 = pub1.authorships.find_by(user: user3)

        expect(auth1.scholarsphere_work_deposits).to match_array [deposit1, deposit2, deposit3]
        expect(auth2.scholarsphere_work_deposits).to eq []
        expect(auth3.scholarsphere_work_deposits).to eq []
      end

      it "transfers visibility" do
        pub1.merge!([pub2, pub3, pub4])

        auth1 = pub1.authorships.find_by(user: user1)
        auth2 = pub1.authorships.find_by(user: user2)
        auth3 = pub1.authorships.find_by(user: user3)

        expect(auth1.visible_in_profile).to eq false
        expect(auth2.visible_in_profile).to eq true
        expect(auth3.visible_in_profile).to eq true
      end

      it "transfers position" do
        pub1.merge!([pub2, pub3, pub4])

        auth1 = pub1.authorships.find_by(user: user1)
        auth2 = pub1.authorships.find_by(user: user2)
        auth3 = pub1.authorships.find_by(user: user3)

        expect(auth1.position_in_profile).to eq 2
        expect(auth2.position_in_profile).to eq nil
        expect(auth3.position_in_profile).to eq nil
      end

      context "when the publication is not visible" do
        it "makes the publication visible" do
          pub1.merge!([pub2, pub3, pub4])

          expect(pub1.reload.visible).to eq true
        end
      end

      context "when the publication is visible" do
        let(:visibility) { true }
        it "leaves the publication visible" do
          pub1.merge!([pub2, pub3, pub4])

          expect(pub1.reload.visible).to eq true
        end
      end
    end

    context "when two of the given publications are in two different non-duplicate groups" do
      let!(:ndpg1) { create :non_duplicate_publication_group, publications: [pub2] }
      let!(:ndpg2) { create :non_duplicate_publication_group, publications: [pub4] }

      it "reassigns all of the imports from the given publications to the publication" do
        pub1.merge!([pub2, pub3, pub4])

        expect(pub1.reload.imports).to match_array [pub1_import1,
                                                    pub2_import1,
                                                    pub2_import2,
                                                    pub3_import1]
      end

      it "deletes the given publications" do
        pub1.merge!([pub2, pub3, pub4])

        expect { pub2.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { pub3.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { pub4.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it "updates the modification timestamp on the publication" do
        pub1.merge!([pub2, pub3, pub4])

        expect(pub1.reload.updated_by_user_at).to be_within(1.minute).of(Time.current)
      end

      it "reassigns the publications to the non-duplicate groups" do
        pub1.merge!([pub2, pub3, pub4])

        expect(ndpg1.reload.publications).to eq [pub1]
        expect(ndpg2.reload.publications).to eq [pub1]
      end

      it "transfers all of the authorships from all of the given publications to the publication" do
        pub1.merge!([pub2, pub3, pub4])

        expect(pub1.authorships.count).to eq 3

        expect(pub1.authorships.find_by(user: user1, author_number: 1)).not_to be_nil
        expect(pub1.authorships.find_by(user: user2, author_number: 2)).not_to be_nil
        expect(pub1.authorships.find_by(user: user3, author_number: 3)).not_to be_nil
      end

      it "transfers authorship confirmation with confirmation presence winning in the event of a conflict" do
        pub1.merge!([pub2, pub3, pub4])

        auth1 = pub1.authorships.find_by(user: user1)
        auth2 = pub1.authorships.find_by(user: user2)
        auth3 = pub1.authorships.find_by(user: user3)

        expect(auth1.confirmed).to eq true
        expect(auth2.confirmed).to eq false
        expect(auth3.confirmed).to eq true
      end

      it "transfers authorship roles" do
        pub1.merge!([pub2, pub3, pub4])

        auth1 = pub1.authorships.find_by(user: user1)
        auth2 = pub1.authorships.find_by(user: user2)
        auth3 = pub1.authorships.find_by(user: user3)

        expect(auth1.role).to eq 'author'
        expect(auth2.role).to eq 'co-author'
        expect(auth3.role).to eq nil
      end

      it "transfers ORCiD identifiers" do
        pub1.merge!([pub2, pub3, pub4])

        auth1 = pub1.authorships.find_by(user: user1)
        auth2 = pub1.authorships.find_by(user: user2)
        auth3 = pub1.authorships.find_by(user: user3)

        expect(auth1.orcid_resource_identifier).to eq 'newer-orcid-identifier'
        expect(auth2.orcid_resource_identifier).to eq 'newer-orcid-identifier-2'
        expect(auth3.orcid_resource_identifier).to eq 'orcid-identifier-3'
      end

      it "transfers open access notification timestamps" do
        pub1.merge!([pub2, pub3, pub4])

        auth1 = pub1.authorships.find_by(user: user1)
        auth2 = pub1.authorships.find_by(user: user2)
        auth3 = pub1.authorships.find_by(user: user3)

        expect(auth1.open_access_notification_sent_at).to eq Time.new(2000, 1, 1, 0, 0, 0)
        expect(auth2.open_access_notification_sent_at).to eq nil
        expect(auth3.open_access_notification_sent_at).to eq Time.new(2010, 1, 1, 0, 0, 0)
      end

      it "transfers owner modification timestamps" do
        pub1.merge!([pub2, pub3, pub4])

        auth1 = pub1.authorships.find_by(user: user1)
        auth2 = pub1.authorships.find_by(user: user2)
        auth3 = pub1.authorships.find_by(user: user3)

        expect(auth1.updated_by_owner_at).to eq Time.new(2021, 1, 1, 0, 0, 0)
        expect(auth2.updated_by_owner_at).to eq Time.new(2021, 1, 1, 0, 0, 0)
        expect(auth3.updated_by_owner_at).to eq Time.new(2020, 1, 1, 0, 0, 0)
      end

      it "transfers waivers" do
        pub1.merge!([pub2, pub3, pub4])

        auth1 = pub1.authorships.find_by(user: user1)
        auth2 = pub1.authorships.find_by(user: user2)
        auth3 = pub1.authorships.find_by(user: user3)

        expect(auth1.waiver).to eq waiver1
        expect(auth2.waiver).to eq nil
        expect(auth3.waiver).to eq nil
      end

      it "transfers ScholarSphere deposits" do
        pub1.merge!([pub2, pub3, pub4])

        auth1 = pub1.authorships.find_by(user: user1)
        auth2 = pub1.authorships.find_by(user: user2)
        auth3 = pub1.authorships.find_by(user: user3)

        expect(auth1.scholarsphere_work_deposits).to match_array [deposit1, deposit2, deposit3]
        expect(auth2.scholarsphere_work_deposits).to eq []
        expect(auth3.scholarsphere_work_deposits).to eq []
      end

      it "transfers visibility" do
        pub1.merge!([pub2, pub3, pub4])

        auth1 = pub1.authorships.find_by(user: user1)
        auth2 = pub1.authorships.find_by(user: user2)
        auth3 = pub1.authorships.find_by(user: user3)

        expect(auth1.visible_in_profile).to eq false
        expect(auth2.visible_in_profile).to eq true
        expect(auth3.visible_in_profile).to eq true
      end

      it "transfers position" do
        pub1.merge!([pub2, pub3, pub4])

        auth1 = pub1.authorships.find_by(user: user1)
        auth2 = pub1.authorships.find_by(user: user2)
        auth3 = pub1.authorships.find_by(user: user3)

        expect(auth1.position_in_profile).to eq 2
        expect(auth2.position_in_profile).to eq nil
        expect(auth3.position_in_profile).to eq nil
      end

      context "when the publication is not visible" do
        it "makes the publication visible" do
          pub1.merge!([pub2, pub3, pub4])

          expect(pub1.reload.visible).to eq true
        end
      end

      context "when the publication is visible" do
        let(:visibility) { true }
        it "leaves the publication visible" do
          pub1.merge!([pub2, pub3, pub4])

          expect(pub1.reload.visible).to eq true
        end
      end
    end

    context "when two of the given publications are in the same non-duplicate group" do
      let!(:ndpg) { create :non_duplicate_publication_group, publications: [pub2, pub4] }

      it "raises an error" do
        expect { pub1.merge!([pub2, pub3, pub4]) }.to raise_error Publication::NonDuplicateMerge
      end

      it "does not reassign any imports" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(pub1.reload.imports).to match_array [pub1_import1]
        expect(pub2.reload.imports).to match_array [pub2_import1, pub2_import2]
        expect(pub3.reload.imports).to match_array [pub3_import1]
        expect(pub4.reload.imports).to eq []
      end

      it "does not delete any publications" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(pub2.reload).to eq pub2
        expect(pub3.reload).to eq pub3
        expect(pub4.reload).to eq pub4
      end

      it "does not update the modification timestamp on the publication" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(pub1.reload.updated_by_user_at).to be_nil
      end

      it "does not update any non-duplicate groups" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(ndpg.reload.publications).to match_array [pub2, pub4]
      end

      it "does not transfer any authorships" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(pub1.authorships.count).to eq 1
        expect(pub1.authorships.find_by(user: user1, author_number: 1)).not_to be_nil
      end

      it "does not transfer any authorship confirmation information" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.confirmed).to eq false
      end

      it "does not transfer any authorship roles" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.role).to be_nil
      end

      it "does not transfer any orcid identifiers" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.orcid_resource_identifier).to eq 'older-orcid-identifier'
      end

      it "does not transfer any open access notification timestamps" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.open_access_notification_sent_at).to eq nil
      end

      it "does not transfer any owner modification timestamps" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.updated_by_owner_at).to eq Time.new(2020, 1, 1, 0, 0, 0)
      end

      it "does not transfer any waivers" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.waiver).to eq nil
      end

      it "does not transfer any ScholarSphere deposits" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.scholarsphere_work_deposits).to eq [deposit3]
      end

      it "does not transfer visibility" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end
        
        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.visible_in_profile).to eq true
      end

      it "does not transfer position" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.position_in_profile).to eq nil
      end

      context "when the publication is not visible" do
        it "does not change the visibility" do
          begin
            pub1.merge!([pub2, pub3, pub4])
          rescue Publication::NonDuplicateMerge; end

          expect(pub1.reload.visible).to eq false
        end
      end

      context "when the publication is visible" do
        let(:visibility) { true }
        it "does not change the visibility" do
          begin
            pub1.merge!([pub2, pub3, pub4])
          rescue Publication::NonDuplicateMerge; end

          expect(pub1.reload.visible).to eq true
        end
      end
    end

    context "when two of the given publications are both in two different non-duplicate group" do
      let!(:ndpg1) { create :non_duplicate_publication_group, publications: [pub2, pub4] }
      let!(:ndpg2) { create :non_duplicate_publication_group, publications: [pub2, pub4] }

      it "raises an error" do
        expect { pub1.merge!([pub2, pub3, pub4]) }.to raise_error Publication::NonDuplicateMerge
      end

      it "does not reassign any imports" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(pub1.reload.imports).to match_array [pub1_import1]
        expect(pub2.reload.imports).to match_array [pub2_import1, pub2_import2]
        expect(pub3.reload.imports).to match_array [pub3_import1]
        expect(pub4.reload.imports).to eq []
      end

      it "does not delete any publications" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(pub2.reload).to eq pub2
        expect(pub3.reload).to eq pub3
        expect(pub4.reload).to eq pub4
      end

      it "does not update the modification timestamp on the publication" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(pub1.reload.updated_by_user_at).to be_nil
      end

      it "does not update any non-duplicate groups" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(ndpg1.reload.publications).to match_array [pub2, pub4]
        expect(ndpg2.reload.publications).to match_array [pub2, pub4]
      end

      it "does not transfer any authorships" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(pub1.authorships.count).to eq 1
        expect(pub1.authorships.find_by(user: user1, author_number: 1)).not_to be_nil
      end

      it "does not transfer any authorship confirmation information" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.confirmed).to eq false
      end

      it "does not transfer any authorship roles" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.role).to be_nil
      end

      it "does not transfer any orcid identifiers" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.orcid_resource_identifier).to eq 'older-orcid-identifier'
      end

      it "does not transfer any open access notification timestamps" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.open_access_notification_sent_at).to eq nil
      end

      it "does not transfer any owner modification timestamps" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.updated_by_owner_at).to eq Time.new(2020, 1, 1, 0, 0, 0)
      end

      it "does not transfer any waivers" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.waiver).to eq nil
      end

      it "does not transfer any ScholarSphere deposits" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.scholarsphere_work_deposits).to eq [deposit3]
      end

      it "does not transfer visibility" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end
        
        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.visible_in_profile).to eq true
      end

      it "does not transfer position" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.position_in_profile).to eq nil
      end

      context "when the publication is not visible" do
        it "does not change the visibility" do
          begin
            pub1.merge!([pub2, pub3, pub4])
          rescue Publication::NonDuplicateMerge; end

          expect(pub1.reload.visible).to eq false
        end
      end

      context "when the publication is visible" do
        let(:visibility) { true }
        it "does not change the visibility" do
          begin
            pub1.merge!([pub2, pub3, pub4])
          rescue Publication::NonDuplicateMerge; end

          expect(pub1.reload.visible).to eq true
        end
      end
    end

    context "when one of the given publications is in the same non-duplicate group as the publication" do
      let!(:ndpg) { create :non_duplicate_publication_group, publications: [pub1, pub3] }

      it "raises an error" do
        expect { pub1.merge!([pub2, pub3, pub4]) }.to raise_error Publication::NonDuplicateMerge
      end

      it "does not reassign any imports" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(pub1.reload.imports).to match_array [pub1_import1]
        expect(pub2.reload.imports).to match_array [pub2_import1, pub2_import2]
        expect(pub3.reload.imports).to match_array [pub3_import1]
        expect(pub4.reload.imports).to eq []
      end

      it "does not delete any publications" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(pub2.reload).to eq pub2
        expect(pub3.reload).to eq pub3
        expect(pub4.reload).to eq pub4
      end

      it "does not update the modification timestamp on the publication" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(pub1.reload.updated_by_user_at).to be_nil
      end

      it "does not update any non-duplicate groups" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(ndpg.reload.publications).to match_array [pub1, pub3]
      end

      it "does not transfer any authorships" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(pub1.authorships.count).to eq 1
        expect(pub1.authorships.find_by(user: user1, author_number: 1)).not_to be_nil
      end

      it "does not transfer any authorship confirmation information" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.confirmed).to eq false
      end

      it "does not transfer any authorship roles" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.role).to be_nil
      end

      it "does not transfer any orcid identifiers" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.orcid_resource_identifier).to eq 'older-orcid-identifier'
      end

      it "does not transfer any open access notification timestamps" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.open_access_notification_sent_at).to eq nil
      end

      it "does not transfer any owner modification timestamps" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.updated_by_owner_at).to eq Time.new(2020, 1, 1, 0, 0, 0)
      end

      it "does not transfer any waivers" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.waiver).to eq nil
      end

      it "does not transfer any ScholarSphere deposits" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.scholarsphere_work_deposits).to eq [deposit3]
      end

      it "does not transfer visibility" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end
        
        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.visible_in_profile).to eq true
      end

      it "does not transfer position" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.position_in_profile).to eq nil
      end

      context "when the publication is not visible" do
        it "does not change the visibility" do
          begin
            pub1.merge!([pub2, pub3, pub4])
          rescue Publication::NonDuplicateMerge; end

          expect(pub1.reload.visible).to eq false
        end
      end

      context "when the publication is visible" do
        let(:visibility) { true }
        it "does not change the visibility" do
          begin
            pub1.merge!([pub2, pub3, pub4])
          rescue Publication::NonDuplicateMerge; end

          expect(pub1.reload.visible).to eq true
        end
      end
    end

    context "when all of the publications are in the same non-duplicate group" do
      let!(:ndpg) { create :non_duplicate_publication_group, publications: [pub1, pub2, pub3, pub4] }

      it "raises an error" do
        expect { pub1.merge!([pub2, pub3, pub4]) }.to raise_error Publication::NonDuplicateMerge
      end

      it "does not reassign any imports" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(pub1.reload.imports).to match_array [pub1_import1]
        expect(pub2.reload.imports).to match_array [pub2_import1, pub2_import2]
        expect(pub3.reload.imports).to match_array [pub3_import1]
        expect(pub4.reload.imports).to eq []
      end

      it "does not delete any publications" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(pub2.reload).to eq pub2
        expect(pub3.reload).to eq pub3
        expect(pub4.reload).to eq pub4
      end

      it "does not update the modification timestamp on the publication" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(pub1.reload.updated_by_user_at).to be_nil
      end

      it "does not update any non-duplicate groups" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(ndpg.reload.publications).to match_array [pub1, pub2, pub3, pub4]
      end

      it "does not transfer any authorships" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        expect(pub1.authorships.count).to eq 1
        expect(pub1.authorships.find_by(user: user1, author_number: 1)).not_to be_nil
      end

      it "does not transfer any authorship confirmation information" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.confirmed).to eq false
      end

      it "does not transfer any authorship roles" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.role).to be_nil
      end

      it "does not transfer any orcid identifiers" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.orcid_resource_identifier).to eq 'older-orcid-identifier'
      end

      it "does not transfer any open access notification timestamps" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)
        expect(auth1.open_access_notification_sent_at).to eq nil
      end

      it "does not transfer any owner modification timestamps" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.updated_by_owner_at).to eq Time.new(2020, 1, 1, 0, 0, 0)
      end

      it "does not transfer any waivers" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.waiver).to eq nil
      end

      it "does not transfer any ScholarSphere deposits" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.scholarsphere_work_deposits).to eq [deposit3]
      end

      it "does not transfer visibility" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end
        
        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.visible_in_profile).to eq true
      end

      it "does not transfer position" do
        begin
          pub1.merge!([pub2, pub3, pub4])
        rescue Publication::NonDuplicateMerge; end

        auth1 = pub1.authorships.find_by(user: user1)

        expect(auth1.position_in_profile).to eq nil
      end

      context "when the publication is not visible" do
        it "does not change the visibility" do
          begin
            pub1.merge!([pub2, pub3, pub4])
          rescue Publication::NonDuplicateMerge; end

          expect(pub1.reload.visible).to eq false
        end
      end

      context "when the publication is visible" do
        let(:visibility) { true }
        it "does not change the visibility" do
          begin
            pub1.merge!([pub2, pub3, pub4])
          rescue Publication::NonDuplicateMerge; end

          expect(pub1.reload.visible).to eq true
        end
      end
    end
  end

  describe '#all_non_duplicate_ids' do
    let!(:pub) { create :publication }

    let!(:nd1) { create :publication, id: 900000 }
    let!(:nd2) { create :publication, id: 800000 }
    let!(:nd3) { create :publication }

    before do
      create :non_duplicate_publication_group, publications: [pub, nd1, nd2]
      create :non_duplicate_publication_group, publications: [pub, nd2]
    end

    it "returns the IDs of all publications that are known to not be duplicates of the publication" do
      expect(pub.all_non_duplicate_ids).to eq [800000, 900000]
    end
  end

  describe "#has_single_import_from_pure?" do
    let(:pure_import) { build :publication_import, source: "Pure" }
    let(:other_pure_import) { build :publication_import, source: "Pure" }
    let(:ai_import) { build :publication_import, source: "Activity Insight" }

    context "when the publication has an import from Pure" do
      let(:pub) { create :publication, imports: [pure_import] }

      it "returns true" do
        expect(pub.has_single_import_from_pure?).to eq true
      end
    end

    context "when the publication has two imports from Pure" do
      let(:pub) { create :publication, imports: [pure_import, other_pure_import] }

      it "returns false" do
        expect(pub.has_single_import_from_pure?).to eq false
      end
    end

    context "when the publication has an import from Pure and an import from another source" do
      let(:pub) { create :publication, imports: [pure_import, ai_import] }

      it "returns false" do
        expect(pub.has_single_import_from_pure?).to eq false
      end
    end

    context "when the publication does not have any imports" do
      let(:pub) { create :publication }

      it "returns false" do
        expect(pub.has_single_import_from_pure?).to eq false
      end
    end
  end

  describe "#has_single_import_from_ai?" do
    let(:ai_import) { build :publication_import, source: "Activity Insight" }
    let(:other_ai_import) { build :publication_import, source: "Activity Insight" }
    let(:pure_import) { build :publication_import, source: "Pure" }

    context "when the publication has an import from Activity Insight" do
      let(:pub) { create :publication, imports: [ai_import] }

      it "returns true" do
        expect(pub.has_single_import_from_ai?).to eq true
      end
    end

    context "when the publication two imports from Activity Insight" do
      let(:pub) { create :publication, imports: [ai_import, other_ai_import] }

      it "returns false" do
        expect(pub.has_single_import_from_ai?).to eq false
      end
    end

    context "when the publication has an import from Activity Insight and an import from another source" do
      let(:pub) { create :publication, imports: [ai_import, pure_import] }

      it "returns false" do
        expect(pub.has_single_import_from_ai?).to eq false
      end
    end

    context "when the publication does not have any imports" do
      let(:pub) { create :publication }

      it "returns false" do
        expect(pub.has_single_import_from_ai?).to eq false
      end
    end
  end

  describe '#is_journal_article?' do
    context 'when publication is a Journal Article' do
      let!(:pub1) { FactoryBot.create :publication, publication_type: 'Journal Article' }
      it 'returns true' do
        expect(pub1.is_journal_article?).to eq true
      end
    end

    context 'when publication is a Book' do
      let!(:pub2) { FactoryBot.create :publication, publication_type: 'Book' }
      it 'returns false' do
        expect(pub2.is_journal_article?).to eq false
      end
    end
  end

  describe '#preferred_journal_title' do
    let(:pub) { Publication.new }
    let(:policy) { double 'preferred journal info policy', journal_title: 'preferred title' }
    before { allow(PreferredJournalInfoPolicy).to receive(:new).with(pub).and_return(policy) }
    it 'delegates to the preferred journal info policy' do
      expect(pub.preferred_journal_title).to eq 'preferred title'
    end
  end

  describe '#preferred_publisher_name' do
    let(:pub) { Publication.new }
    let(:policy) { double 'preferred journal info policy', publisher_name: 'preferred name' }
    before { allow(PreferredJournalInfoPolicy).to receive(:new).with(pub).and_return(policy) }
    it 'delegates to the preferred journal info policy' do
      expect(pub.preferred_publisher_name).to eq 'preferred name'
    end
  end

  describe "#published" do
    context "when publication's status is 'Published" do
      let(:pub) { FactoryBot.create :publication, status: 'Published' }

      it 'returns true' do
        expect(pub.published?).to eq true
      end
    end

    context "when publication's status is 'In Press'" do
      let(:pub) { FactoryBot.create :publication, status: 'In Press' }

      it 'returns false' do
        expect(pub.published?).to eq false
      end
    end
  end
end
