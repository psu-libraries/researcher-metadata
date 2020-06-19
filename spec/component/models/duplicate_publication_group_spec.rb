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

      # three publications that match perfectly
      let!(:p1_1) { create :publication,
                           title: "Publication with an Exactly Duplicated Title",
                           published_on: Date.new(2000, 1, 1),
                           doi: "https://doi.org/some-doi-123456789" }
                         
      let!(:p1_2) { create :publication,
                           title: "Publication with an Exactly Duplicated Title",
                           published_on: Date.new(2000, 1, 1),
                           doi: "https://doi.org/some-doi-123456789" }

      let!(:p1_3) { create :publication,
                           title: "Publication with an Exactly Duplicated Title",
                           published_on: Date.new(2000, 1, 1),
                           doi: "https://doi.org/some-doi-123456789" }

      # two publications that have similar titles and otherwise match
      let!(:p2_1) { create :publication,
                           title: "Multiple-Exponential Electron Injection in Ru(dcbpy)<sub>2</sub>(SCN)<sub>2</sub> Sensitized ZnO Nanocrystalline Thin Films",
                           published_on: Date.new(2000, 1, 1),
                           doi: "https://doi.org/some-doi-987654321" }
                         
      let!(:p2_2) { create :publication,
                           title: "Multiple-exponential electron injection in Ru(dcbpy)(2)(SCN)(2) sensitized ZnO nanocrystalline thin films",
                           published_on: Date.new(2000, 1, 1),
                           doi: "https://doi.org/some-doi-987654321" }

      # two publications with somewhat different titles and the same publication date
      let!(:p3_1) { create :publication,
                           title: "Utilizing cloud computing to address big geospatial data challenges",
                           published_on: Date.new(2000, 1, 1),
                           doi: nil }
                         
      let!(:p3_2) { create :publication,
                           title: "Utilizing cloud computing to do something entirely different with big data sets",
                           published_on: Date.new(2000, 1, 1),
                           doi: nil }

      # two publications with similar titles and no other data
      let!(:p4_1) { create :publication,
                           title: "Telomeric (TTAGGG)n sequences are associated with nucleolus organizer regions (NORs) in the wood lemming",
                           published_on: nil,
                           doi: nil }
                         
      let!(:p4_2) { create :publication,
                           title: "Telomeric (TTAGGG)(n) sequences are associated with nucleolus organizer regions (NORs) in the wood lemming",
                           published_on: nil,
                           doi: nil }

      # two publications with similar titles and different publication dates that have the same year
      let!(:p5_1) { create :publication,
                           title: "Observation and properties of the X(3872) decaying to J/ψπ<sup>+</sup>π<sup>-</sup> in pp̄ collisions at √s = 1.96 TeV",
                           published_on: Date.new(2000, 5, 20),
                           doi: nil }
                         
      let!(:p5_2) { create :publication,
                           title: "Observation and properties of the X(3872) decaying to J/psi pi(+)pi(-) in p(p)over-bar collisions at root s=1.96 TeV",
                           published_on: Date.new(2000, 1, 1),
                           doi: nil }

      # two publications with the same title and publication date but with different DOIs
      let!(:p6_1) { create :publication,
                           title: "A Really Generic Title",
                           published_on: Date.new(2000, 1, 1),
                           doi: "https://doi.org/some-doi-23456431" }
                         
      let!(:p6_2) { create :publication,
                           title: "A Really Generic Title",
                           published_on: Date.new(2000, 1, 1),
                           doi: "https://doi.org/some-doi-4563457245" }

      # two publications with the same title where only one has a DOI and publication date
      let!(:p7_1) { create :publication,
                           title: "A Publication That Matches Another Publication",
                           published_on: Date.new(2000, 1, 1),
                           doi: "https://doi.org/some-doi-22357534" }
                         
      let!(:p7_2) { create :publication,
                           title: "A Publication That Matches Another Publication",
                           published_on: nil,
                           doi: nil }

      # two publications with the same title where one has the title split between the two title fields
      let!(:p8_1) { create :publication,
                           title: "Assessing and investigating clinicians' research interests",
                           secondary_title: "Lessons on expanding practices and data collection in a large practice research network",
                           published_on: nil,
                           doi: nil }
                         
      let!(:p8_2) { create :publication,
                           title: "Assessing and investigating clinicians' research interests: Lessons on expanding practices and data collection in a large practice research network",
                           secondary_title: nil,
                           published_on: nil,
                           doi: nil }

      # a publication that is already in a group that has the same title as other publications
      let!(:p1) { create :publication,
                         title: "Publication with an Exactly Duplicated Title",
                         duplicate_group: existing_group1 }

      it "finds similar publications and groups them" do
        expect { DuplicatePublicationGroup.group_duplicates }.to change { DuplicatePublicationGroup.count }.by 5

        expect(p1_1.reload.duplicate_group.publications).to match_array [p1_1, p1_2, p1_3, p1]
        expect(p2_1.reload.duplicate_group.publications).to match_array [p2_1, p2_2]
        expect(p3_1.reload.duplicate_group).to be_nil
        expect(p3_2.reload.duplicate_group).to be_nil
        expect(p4_1.reload.duplicate_group.publications).to match_array [p4_1, p4_2]
        expect(p5_1.reload.duplicate_group.publications).to match_array [p5_1, p5_2]
        expect(p6_1.reload.duplicate_group).to be_nil
        expect(p6_2.reload.duplicate_group).to be_nil
        expect(p7_1.reload.duplicate_group.publications).to match_array [p7_1, p7_2]
        expect(p8_1.reload.duplicate_group.publications).to match_array [p8_1, p8_2]
      end

      it "is idempotent" do
        expect { 2.times { DuplicatePublicationGroup.group_duplicates } }.to change { DuplicatePublicationGroup.count }.by 5

        expect(p1_1.reload.duplicate_group.publications).to match_array [p1_1, p1_2, p1_3, p1]
        expect(p2_1.reload.duplicate_group.publications).to match_array [p2_1, p2_2]
        expect(p3_1.reload.duplicate_group).to be_nil
        expect(p3_2.reload.duplicate_group).to be_nil
        expect(p4_1.reload.duplicate_group.publications).to match_array [p4_1, p4_2]
        expect(p5_1.reload.duplicate_group.publications).to match_array [p5_1, p5_2]
        expect(p6_1.reload.duplicate_group).to be_nil
        expect(p6_2.reload.duplicate_group).to be_nil
        expect(p7_1.reload.duplicate_group.publications).to match_array [p7_1, p7_2]
        expect(p8_1.reload.duplicate_group.publications).to match_array [p8_1, p8_2]
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
