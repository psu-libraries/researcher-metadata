require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the duplicate_publication_groups table', type: :model do
  subject { DuplicatePublicationGroup.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
end

describe DuplicatePublicationGroup, type: :model do
  subject(:dpg) { DuplicatePublicationGroup.new }

  it_behaves_like "an application record"

  it { is_expected.to have_many(:publications).inverse_of(:duplicate_group) }

  describe '.group_duplicates' do
    context "when many publications exist, and some have similar data" do
      let!(:p1) { create :publication,
                         title: "Publication with an Exactly Duplicated Title",
                         volume: 1,
                         issue: 1,
                         journal_title: "Journal 1",
                         publisher: "Publisher 1",
                         published_on: Date.new(2018, 1, 1) }

      let!(:p2) { create :publication,
                         title: "Publication with an Exactly Duplicated Title",
                         volume: 2,
                         issue: 1,
                         journal_title: "Journal 1",
                         publisher: "Publisher 1",
                         published_on: Date.new(2018, 1, 1) }

      let!(:p3) { create :publication,
                         title: "Publication with an Exactly Duplicated Title",
                         volume: 1,
                         issue: 2,
                         journal_title: "Journal 1",
                         publisher: "Publisher 1",
                         published_on: Date.new(2018, 1, 1) }

      let!(:p4) { create :publication,
                         title: "Publication with an Exactly Duplicated Title",
                         volume: 1,
                         issue: 1,
                         journal_title: "Journal 2",
                         publisher: "Publisher 1",
                         published_on: Date.new(2018, 1, 1) }

      let!(:p5) { create :publication,
                         title: "Publication with an Exactly Duplicated Title",
                         volume: 1,
                         issue: 1,
                         journal_title: "Journal 1",
                         publisher: "Publisher 2",
                         published_on: Date.new(2018, 1, 1) }

      let!(:p6) { create :publication,
                         title: "Publication with an Exactly Duplicated Title",
                         volume: 1,
                         issue: 1,
                         journal_title: "Journal 1",
                         publisher: "Publisher 1",
                         published_on: Date.new(2017, 1, 1) }

      let!(:p7) { create :publication,
                         title: "Publication with an Exactly Duplicated Title",
                         volume: 1,
                         issue: 1,
                         journal_title: "Journal 1",
                         publisher: "Publisher 1",
                         published_on: Date.new(2018, 1, 2) }

      let!(:p8) { create :publication,
                         title: "Publication with an Exactly Duplicated Title",
                         volume: 1,
                         issue: 1,
                         journal_title: "Journal 1",
                         publisher: "Publisher 1",
                         published_on: Date.new(2018, 1, 1) }

      let!(:p9) { create :publication,
                         title: "Publication with an Exactly Duplicated Title",
                         volume: 1,
                         issue: 1,
                         journal_title: "Journal 1",
                         publisher: "Publisher 1",
                         published_on: Date.new(2018, 1, 1) }

      let!(:p10) { create :publication,
                          title: "Publication with Duplicated Title that Differs Only by Case",
                          volume: 1,
                          issue: 1,
                          journal_title: "Journal 1",
                          publisher: "Publisher 1",
                          published_on: Date.new(2018, 1, 1) }

      let!(:p11) { create :publication,
                          title: "publication with duplicated title that differs only by case",
                          volume: 1,
                          issue: 1,
                          journal_title: "Journal 1",
                          publisher: "Publisher 1",
                          published_on: Date.new(2018, 1, 1) }

      let!(:p12) { create :publication,
                          title: "Duplicate Publication Where Journal Matches Publisher",
                          volume: 1,
                          issue: 1,
                          journal_title: "Journal 1",
                          publisher: nil,
                          published_on: Date.new(2018, 1, 1) }

      let!(:p13) { create :publication,
                          title: "Duplicate Publication Where Journal Matches Publisher",
                          volume: 1,
                          issue: 1,
                          journal_title: nil,
                          publisher: "Journal 1",
                          published_on: Date.new(2018, 1, 1) }

      let!(:p14) { create :publication,
                          title: "Other Publication with No Matching Title",
                          volume: 1,
                          issue: 1,
                          journal_title: nil,
                          publisher: "Journal 1",
                          published_on: Date.new(2018, 1, 1) }

      let!(:p15) { create :publication,
                          title: "Publication with Title that Partially Matches Other Titles",
                          volume: 1,
                          issue: 1,
                          journal_title: "Journal 1",
                          publisher: "Publisher 1",
                          published_on: Date.new(2018, 1, 1) }

      let!(:p16) { create :publication,
                          title: "Publication with Title that Partially",
                          volume: 1,
                          issue: 1,
                          journal_title: "Journal 1",
                          publisher: "Publisher 1",
                          published_on: Date.new(2018, 1, 1) }

      let!(:p17) { create :publication,
                          title: "Title that Partially Matches",
                          volume: 1,
                          issue: 1,
                          journal_title: "Journal 1",
                          publisher: "Publisher 1",
                          published_on: Date.new(2018, 1, 1) }

      let!(:p18) { create :publication,
                          title: "Partially Matches Other Titles",
                          volume: 1,
                          issue: 1,
                          journal_title: "Journal 1",
                          publisher: "Publisher 1",
                          published_on: Date.new(2018, 1, 1) }

      let!(:p19) { create :publication,
                          title: "Duplicate Publication Where Journal Differs Only by Case",
                          volume: 1,
                          issue: 1,
                          journal_title: "Journal 1",
                          publisher: "Publisher 1",
                          published_on: Date.new(2018, 1, 1) }

      let!(:p20) { create :publication,
                          title: "Duplicate Publication Where Journal Differs Only by Case",
                          volume: 1,
                          issue: 1,
                          journal_title: "JOURNAL 1",
                          publisher: "Publisher 1",
                          published_on: Date.new(2018, 1, 1) }

      it "finds similar publications and groups them" do
        expect { DuplicatePublicationGroup.group_duplicates }.to change { DuplicatePublicationGroup.count }.by 5

        expect(p1.reload.duplicate_group.publications).to match_array [p1, p4, p5, p7, p8, p9]
        expect(p2.reload.duplicate_group).to be_nil
        expect(p3.reload.duplicate_group).to be_nil
        expect(p6.reload.duplicate_group).to be_nil
        expect(p10.reload.duplicate_group.publications).to match_array [p10, p11]
        expect(p12.reload.duplicate_group.publications).to match_array [p12, p13]
        expect(p14.reload.duplicate_group).to be_nil
        expect(p15.reload.duplicate_group.publications).to match_array [p15, p16, p17, p18]
        expect(p19.reload.duplicate_group.publications).to match_array [p19, p20]
      end

      it "is idempotent" do
        expect { 2.times { DuplicatePublicationGroup.group_duplicates } }.to change { DuplicatePublicationGroup.count }.by 5

        expect(p1.reload.duplicate_group.publications).to match_array [p1, p4, p5, p7, p8, p9]
        expect(p2.reload.duplicate_group).to be_nil
        expect(p3.reload.duplicate_group).to be_nil
        expect(p6.reload.duplicate_group).to be_nil
        expect(p10.reload.duplicate_group.publications).to match_array [p10, p11]
        expect(p12.reload.duplicate_group.publications).to match_array [p12, p13]
        expect(p14.reload.duplicate_group).to be_nil
        expect(p15.reload.duplicate_group.publications).to match_array [p15, p16, p17, p18]
        expect(p19.reload.duplicate_group.publications).to match_array [p19, p20]
      end
    end
  end
end
