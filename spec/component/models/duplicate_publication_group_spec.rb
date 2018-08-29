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
      let!(:existing_group1) { create :duplicate_publication_group }
      let!(:existing_group2) { create :duplicate_publication_group }

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
                         published_on: Date.new(2018, 1, 1),
                         duplicate_group: existing_group1 }

      let!(:p5) { create :publication,
                         title: "Publication with an Exactly Duplicated Title",
                         volume: 1,
                         issue: 1,
                         journal_title: "Journal 1",
                         publisher: "Publisher 2",
                         published_on: Date.new(2018, 1, 1),
                         duplicate_group: existing_group2 }

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

      let!(:p21) { create :publication, duplicate_group: existing_group1 }
      let!(:p22) { create :publication, duplicate_group: existing_group2 }

      it "finds similar publications and groups them" do
        expect { DuplicatePublicationGroup.group_duplicates }.to change { DuplicatePublicationGroup.count }.by 3

        expect(p1.reload.duplicate_group.publications).to match_array [p1, p4, p5, p7, p8, p9, p21, p22]
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
        expect { 2.times { DuplicatePublicationGroup.group_duplicates } }.to change { DuplicatePublicationGroup.count }.by 3

        expect(p1.reload.duplicate_group.publications).to match_array [p1, p4, p5, p7, p8, p9, p21, p22]
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

  describe '.group_publications' do
    let!(:pub1) { create :publication }

    context "when given no publications" do
      it "does not create any new duplicate publication groups" do
        expect { DuplicatePublicationGroup.group_publications([]) }.not_to change { DuplicatePublicationGroup.count }
      end
    end
    context "when given one publication" do
      it "does not create any new duplicate publication groups" do
        expect { DuplicatePublicationGroup.group_publications([pub1]) }.not_to change { DuplicatePublicationGroup.count }
      end
    end
    context "when given multiple publications" do
      let!(:pub2) { create :publication }
      let!(:pub3) { create :publication }
      let!(:other_pub) { create :publication }
      let!(:existing_group1) { create :duplicate_publication_group }
      let!(:existing_group2) { create :duplicate_publication_group }
      let!(:grouped_pub1) { create :publication, duplicate_group: existing_group1 }
      let!(:grouped_pub2) { create :publication, duplicate_group: existing_group1 }
      let!(:grouped_pub3) { create :publication, duplicate_group: existing_group2 }
      let!(:grouped_pub4) { create :publication, duplicate_group: existing_group2 }

      context "when none of the publications belong to a duplicate group" do
        it "creates a new duplicate group" do
          expect { DuplicatePublicationGroup.group_publications([pub1, pub2, pub3]) }.to change { DuplicatePublicationGroup.count }.by 1
        end

        it "adds each given publication to the group" do
          DuplicatePublicationGroup.group_publications([pub1, pub2, pub3])

          new_group = pub1.reload.duplicate_group

          expect(new_group.publications).to match_array [pub1, pub2, pub3]
        end
      end

      context "when one of the publications already belongs to a duplicate group" do
        it "does not create any new duplicate publication groups" do
          expect { DuplicatePublicationGroup.group_publications([pub1, pub2, grouped_pub1]) }.not_to change { DuplicatePublicationGroup.count }
        end

        it "adds all of the given publications to the existing group" do
          DuplicatePublicationGroup.group_publications([pub1, pub2, grouped_pub1])

          expect(existing_group1.reload.publications).to match_array [pub1, pub2, grouped_pub1, grouped_pub2]
        end
      end

      context "when two of the given publications already belong to the same duplicate group" do
        it "does not create any new duplicate publication groups" do
          expect { DuplicatePublicationGroup.group_publications([pub2, grouped_pub1, grouped_pub2]) }.not_to change { DuplicatePublicationGroup.count }
        end

        it "adds all of the given publications to the existing group" do
          DuplicatePublicationGroup.group_publications([pub2, grouped_pub1, grouped_pub2])

          expect(existing_group1.reload.publications).to match_array [pub2, grouped_pub1, grouped_pub2]
        end
      end

      context "when two of the given publications already belong to different duplicate groups" do
        it "removes one of the existing duplicate groups" do
          expect { DuplicatePublicationGroup.group_publications([pub2, grouped_pub1, grouped_pub3]) }.to change { DuplicatePublicationGroup.count }.by -1
        end

        it "adds all of the given publications and the other members of their groups to the remaining existing group" do
          DuplicatePublicationGroup.group_publications([pub2, grouped_pub1, grouped_pub3])

          remaining_group = grouped_pub1.reload.duplicate_group || grouped_pub3.reload.duplicate_group

          expect(remaining_group.publications).to match_array [pub2,
                                                               grouped_pub1,
                                                               grouped_pub2,
                                                               grouped_pub3,
                                                               grouped_pub4]
        end
      end
    end
  end

  describe '#publication_count' do
    let!(:dpg) { create :duplicate_publication_group }
    before { 2.times { create :publication, duplicate_group: dpg } }
    it "returns the number of publications that belong to the group" do
      expect(dpg.publication_count).to eq 2
    end
  end

  describe '#first_publication_title' do
    let!(:dpg) { create :duplicate_publication_group }
    context "when the group has no publications" do
      it "returns nil" do
        expect(dpg.first_publication_title).to be_nil
      end
    end

    context "when the group has publications" do
      before do
        create :publication, duplicate_group: dpg, title: 'First Pub'
        create :publication, duplicate_group: dpg, title: 'Second Pub'
      end

      it "returns the title of the first publication in the group" do
        expect(dpg.first_publication_title).to eq 'First Pub'
      end
    end
  end
end
