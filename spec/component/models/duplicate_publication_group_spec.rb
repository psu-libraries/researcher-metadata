# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = nil

describe 'the duplicate_publication_groups table', type: :model do
  subject { DuplicatePublicationGroup.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
end

describe DuplicatePublicationGroup, type: :model do
  subject(:dpg) { described_class.new }

  it_behaves_like 'an application record'

  it { is_expected.to have_many(:publications).inverse_of(:duplicate_group) }

  describe '.group_duplicates' do
    context 'when many publications exist, and some have similar data' do
      let!(:existing_group1) { create :duplicate_publication_group }
      let!(:existing_group2) { create :duplicate_publication_group }

      # three publications that match perfectly
      let!(:p1_1) { create :publication,
                           title: 'Publication with an Exactly Duplicated Title',
                           published_on: Date.new(2000, 1, 1),
                           doi: 'https://doi.org/10.000/some-doi-123456789' }

      let!(:p1_2) { create :publication,
                           title: 'Publication with an Exactly Duplicated Title',
                           published_on: Date.new(2000, 1, 1),
                           doi: 'https://doi.org/10.000/some-doi-123456789' }

      let!(:p1_3) { create :publication,
                           title: 'Publication with an Exactly Duplicated Title',
                           published_on: Date.new(2000, 1, 1),
                           doi: 'https://doi.org/10.000/some-doi-123456789' }

      # a publication that is already in a group that has the same title as other publications
      let!(:p1) { create :publication,
                         title: 'Publication with an Exactly Duplicated Title',
                         duplicate_group: existing_group1 }

      # two publications that have similar titles and otherwise match
      let!(:p2_1) { create :publication,
                           title: 'Multiple-Exponential Electron Injection in Ru(dcbpy)<sub>2</sub>(SCN)<sub>2</sub> Sensitized ZnO Nanocrystalline Thin Films',
                           published_on: Date.new(2000, 1, 1),
                           doi: 'https://doi.org/10.000/some-doi-987654321' }

      let!(:p2_2) { create :publication,
                           title: 'Multiple-exponential electron injection in Ru(dcbpy)(2)(SCN)(2) sensitized ZnO nanocrystalline thin films',
                           published_on: Date.new(2000, 1, 1),
                           doi: 'https://doi.org/10.000/some-doi-987654321' }

      # two publications with somewhat different titles and the same publication date
      let!(:p3_1) { create :publication,
                           title: 'Utilizing cloud computing to address big geospatial data challenges',
                           published_on: Date.new(2000, 1, 1),
                           doi: nil }

      let!(:p3_2) { create :publication,
                           title: 'Utilizing cloud computing to do something entirely different with big data sets',
                           published_on: Date.new(2000, 1, 1),
                           doi: nil }

      # two publications with similar titles and no other data
      let!(:p4_1) { create :publication,
                           title: 'Telomeric (TTAGGG)n sequences are associated with nucleolus organizer regions (NORs) in the wood lemming',
                           published_on: nil,
                           doi: nil }

      let!(:p4_2) { create :publication,
                           title: 'Telomeric (TTAGGG)(n) sequences are associated with nucleolus organizer regions (NORs) in the wood lemming',
                           published_on: nil,
                           doi: nil }

      # two publications with similar titles and different publication dates that have the same year
      let!(:p5_1) { create :publication,
                           title: 'Observation and properties of the X(3872) decaying to J/ψπ<sup>+</sup>π<sup>-</sup> in pp̄ collisions at √s = 1.96 TeV',
                           published_on: Date.new(2000, 5, 20),
                           doi: nil }

      let!(:p5_2) { create :publication,
                           title: 'Observation and properties of the X(3872) decaying to J/psi pi(+)pi(-) in p(p)over-bar collisions at root s=1.96 TeV',
                           published_on: Date.new(2000, 1, 1),
                           doi: nil }

      # two publications with the same title and publication date but with different DOIs
      let!(:p6_1) { create :publication,
                           title: 'A Really Generic Title',
                           published_on: Date.new(2000, 1, 1),
                           doi: 'https://doi.org/10.000/some-doi-23456431' }

      let!(:p6_2) { create :publication,
                           title: 'A Really Generic Title',
                           published_on: Date.new(2000, 1, 1),
                           doi: 'https://doi.org/10.000/some-doi-4563457245' }

      # two publications with the same title where only one has a DOI and publication date
      let!(:p7_1) { create :publication,
                           title: 'A Publication That Matches Another Publication',
                           published_on: Date.new(2000, 1, 1),
                           doi: 'https://doi.org/10.000/some-doi-22357534' }

      let!(:p7_2) { create :publication,
                           title: 'A Publication That Matches Another Publication',
                           published_on: nil,
                           doi: nil }

      # two publications with the same title where one has the title split between the two title fields
      let!(:p8_1) { create :publication,
                           title: "Assessing and investigating clinicians' research interests",
                           secondary_title: 'Lessons on expanding practices and data collection in a large practice research network',
                           published_on: nil,
                           doi: nil }

      let!(:p8_2) { create :publication,
                           title: "Assessing and investigating clinicians' research interests: Lessons on expanding practices and data collection in a large practice research network",
                           secondary_title: nil,
                           published_on: nil,
                           doi: nil }

      # two publications that match but are in the same non-duplicate publication group
      let!(:p9_1) { create :publication,
                           title: 'Same as another publication but grouped as false-positive',
                           published_on: Date.new(1980, 1, 1),
                           doi: 'https://doi.org/10.000/some-doi-234623613' }

      let!(:p9_2) { create :publication,
                           title: 'Same as another publication but grouped as false-positive',
                           published_on: Date.new(1980, 1, 1),
                           doi: 'https://doi.org/10.000/some-doi-234623613' }

      let!(:p9_ndpg) { create :non_duplicate_publication_group,
                              publications: [p9_1, p9_2] }

      # two publications that match and are in different non-duplicate publication groups
      let!(:p10_1) { create :publication,
                            title: 'In a different false-positive group from the match',
                            published_on: Date.new(1981, 1, 1),
                            doi: 'https://doi.org/10.000/some-doi-854537454' }

      let!(:p10_2) { create :publication,
                            title: 'In a different false-positive group from the match',
                            published_on: Date.new(1981, 1, 1),
                            doi: 'https://doi.org/10.000/some-doi-854537454' }

      let!(:other1) { create :publication, title: 'uquwegflkqulkuagekahkwehf' }
      let!(:other2) { create :publication, title: 'kvbkbcbebbcubibekubkubeuke' }

      let!(:p_10_ndpg1) { create :non_duplicate_publication_group,
                                 publications: [p10_1, other1] }

      let!(:p_10_ndpg2) { create :non_duplicate_publication_group,
                                 publications: [p10_2, other2] }

      # three publications that match but are in the same non-duplicate publication group
      let!(:p11_1) { create :publication,
                            title: 'One in a group of three matching false-positives',
                            published_on: Date.new(1982, 1, 1),
                            doi: 'https://doi.org/10.000/some-doi-3463473' }

      let!(:p11_2) { create :publication,
                            title: 'One in a group of three matching false-positives',
                            published_on: Date.new(1982, 1, 1),
                            doi: 'https://doi.org/10.000/some-doi-3463473' }

      let!(:p11_3) { create :publication,
                            title: 'One in a group of three matching false-positives',
                            published_on: Date.new(1982, 1, 1),
                            doi: 'https://doi.org/10.000/some-doi-3463473' }

      let!(:p_11_ndpg) { create :non_duplicate_publication_group,
                                publications: [p11_1, p11_2, p11_3] }

      # three publications that match where only two are in the same non-duplicate publication group
      let!(:p12_1) { create :publication,
                            title: 'Publication with a two matches where one might not be legit',
                            published_on: Date.new(1983, 1, 1),
                            doi: 'https://doi.org/10.000/some-doi-234534363' }

      let!(:p12_2) { create :publication,
                            title: 'Publication with a two matches where one might not be legit',
                            published_on: Date.new(1983, 1, 1),
                            doi: 'https://doi.org/10.000/some-doi-234534363' }

      let!(:p12_3) { create :publication,
                            title: 'Publication with a two matches where one might not be legit',
                            published_on: Date.new(1983, 1, 1),
                            doi: 'https://doi.org/10.000/some-doi-234534363' }

      let!(:p_12_ndpg) { create :non_duplicate_publication_group,
                                publications: [p12_1, p12_3] }

      # two publications that match and that each belong to two identical non-duplicate publication groups
      let!(:p13_1) { create :publication,
                            title: 'Publication in two identical false-positive groups with another publication',
                            published_on: Date.new(1984, 1, 1),
                            doi: 'https://doi.org/10.000/some-doi-956525657' }

      let!(:p13_2) { create :publication,
                            title: 'Publication in two identical false-positive groups with another publication',
                            published_on: Date.new(1984, 1, 1),
                            doi: 'https://doi.org/10.000/some-doi-956525657' }

      let!(:p13_ndpg1) { create :non_duplicate_publication_group,
                                publications: [p13_1, p13_2] }
      let!(:p13_ndpg2) { create :non_duplicate_publication_group,
                                publications: [p13_1, p13_2] }

      # four publications that match where two belong to one non-duplicate publication group and the other
      # two belong to a different group
      # I'm not sure that this one would ever occur in real life, but it's good to think about
      # what would happen if it somehow did.
      let!(:p14_1) { create :publication,
                            title: 'One of four matches in two different false-positive groups',
                            published_on: Date.new(1985, 1, 1),
                            doi: 'https://doi.org/10.000/some-doi-45782186' }

      let!(:p14_2) { create :publication,
                            title: 'One of four matches in two different false-positive groups',
                            published_on: Date.new(1985, 1, 1),
                            doi: 'https://doi.org/10.000/some-doi-45782186' }

      let!(:p14_3) { create :publication,
                            title: 'One of four matches in two different false-positive groups',
                            published_on: Date.new(1985, 1, 1),
                            doi: 'https://doi.org/10.000/some-doi-45782186' }

      let!(:p14_4) { create :publication,
                            title: 'One of four matches in two different false-positive groups',
                            published_on: Date.new(1985, 1, 1),
                            doi: 'https://doi.org/10.000/some-doi-45782186' }

      let!(:p_14_ndpg1) { create :non_duplicate_publication_group,
                                 publications: [p14_1, p14_2] }
      let!(:p_14_ndpg2) { create :non_duplicate_publication_group,
                                 publications: [p14_3, p14_4] }

      # two publications with the same title where only one has a publication date and one has a blank DOI
      let!(:p15_1) { create :publication,
                            title: 'A Perfect Title Match Where a DOI is blank',
                            published_on: Date.new(2000, 1, 1),
                            doi: 'https://doi.org/10.000/some-doi-22357534' }

      let!(:p15_2) { create :publication,
                            title: 'A Perfect Title Match Where a DOI is blank',
                            published_on: nil,
                            doi: '' }

      # two publications that match except for DOI and one has only an Activity Insight import
      let!(:p16_1) { create :publication,
                            title: "A match where there's a junk DOI from Activity Insight",
                            published_on: Date.new(1986, 1, 1),
                            doi: 'https://doi.org/10.000/some-doi-457472486' }

      let!(:p16_2) { create :publication,
                            title: "A match where there's a junk DOI from Activity Insight",
                            published_on: Date.new(1986, 1, 1),
                            doi: 'https://doi.org/10.000/junk' }

      let!(:p16_2_import_1) { create :publication_import,
                                     source: 'Activity Insight',
                                     publication: p16_2}

      # two publications that match except for DOI and one has an Activity Insight import and a Pure import
      let!(:p17_1) { create :publication,
                            title: 'consider DOI because AI is not the only import',
                            published_on: Date.new(1987, 1, 1),
                            doi: 'https://doi.org/10.000/some-doi-457472486' }

      let!(:p17_2) { create :publication,
                            title: 'consider DOI because AI is not the only import',
                            published_on: Date.new(1987, 1, 1),
                            doi: 'https://doi.org/10.000/junk' }

      let!(:p17_2_import_1) { create :publication_import,
                                     source: 'Activity Insight',
                                     publication: p17_2}

      let!(:p17_2_import_2) { create :publication_import,
                                     source: 'Pure',
                                     publication: p17_2}

      it 'creates the correct number of duplicate groups' do
        expect { described_class.group_duplicates }.to change(described_class, :count).by 10
      end

      it 'finds similar publications and groups them' do
        described_class.group_duplicates

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

        expect(p9_1.reload.duplicate_group).to be_nil
        expect(p9_2.reload.duplicate_group).to be_nil

        expect(p10_1.reload.duplicate_group.publications).to match_array [p10_1, p10_2]

        expect(p11_1.reload.duplicate_group).to be_nil
        expect(p11_2.reload.duplicate_group).to be_nil
        expect(p11_3.reload.duplicate_group).to be_nil

        # This one is a little counter-intuitive, but it's probably the right behavior.
        # The second publication here ties together the first and the third which have
        # been grouped as false-positive matches of each other. The second publication
        # could be a true match for either the first or the third (but not both). Thus
        # they all need to be placed into the same duplicate group together so that
        # they can be sorted out. In that scenario a few things could happen:
        #   1. We might say that second publication is also a false match for both the
        #      first and the third. In that case, we'd select all three, put them into
        #      a new group of false-positives, and delete the duplicate group.
        #   2. We might say that the second publication is a true match for the first, and we
        #      merge the first publication into the second thereby deleting the first. This
        #      leaves a false-positive group with only the third publication as a member.
        #      The second publication and the third publication have to be a false-positive
        #      match (by the transitive property of equality!) so we put them into a new
        #      false-positive group and delete the duplicate group.
        #   3. We might say that the second publication is a true match for the first, and
        #      we merge the second publication into the first (opposite of #2 above) thereby
        #      deleting the second. Now we're left with a duplicate group that contains the
        #      same publications (the first and the third) as a false-positive group.
        #      Although this duplicate group still exists, it wouldn't get recreated if it
        #      were deleted due to the presence of the false-positive group. In practice,
        #      our workflow will probably require us to create a second false-positive group
        #      containing the first and third publications in order to empty the duplicate
        #      group and allow it to be deleted. This extra record shouldn't cause any
        #      problem, and if anything it will track a little bit of the history of the
        #      deduplication process.
        #   4. The same scenarios as #2 and #3 above may occur only with the second and third
        #      publication being the true match instead of the first and the second.
        expect(p12_1.reload.duplicate_group.publications).to match_array [p12_1, p12_2, p12_3]
        expect(p12_2.reload.duplicate_group.publications).to match_array [p12_1, p12_2, p12_3]
        expect(p12_3.reload.duplicate_group.publications).to match_array [p12_1, p12_2, p12_3]

        expect(p13_1.reload.duplicate_group).to be_nil
        expect(p13_2.reload.duplicate_group).to be_nil

        expect(p14_1.reload.duplicate_group.publications).to match_array [p14_1, p14_2, p14_3, p14_4]
        expect(p14_2.reload.duplicate_group.publications).to match_array [p14_1, p14_2, p14_3, p14_4]
        expect(p14_3.reload.duplicate_group.publications).to match_array [p14_1, p14_2, p14_3, p14_4]
        expect(p14_4.reload.duplicate_group.publications).to match_array [p14_1, p14_2, p14_3, p14_4]

        expect(p15_1.reload.duplicate_group.publications).to match_array [p15_1, p15_2]

        expect(p16_1.reload.duplicate_group.publications).to match_array [p16_1, p16_2]

        expect(p17_1.reload.duplicate_group).to be_nil
        expect(p17_2.reload.duplicate_group).to be_nil
      end

      it 'is idempotent' do
        expect { 2.times { described_class.group_duplicates } }.to change(described_class, :count).by 10

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
        expect(p9_1.reload.duplicate_group).to be_nil
        expect(p9_2.reload.duplicate_group).to be_nil
        expect(p10_1.reload.duplicate_group.publications).to match_array [p10_1, p10_2]
        expect(p11_1.reload.duplicate_group).to be_nil
        expect(p11_2.reload.duplicate_group).to be_nil
        expect(p11_3.reload.duplicate_group).to be_nil
        expect(p12_1.reload.duplicate_group.publications).to match_array [p12_1, p12_2, p12_3]
        expect(p12_2.reload.duplicate_group.publications).to match_array [p12_1, p12_2, p12_3]
        expect(p12_3.reload.duplicate_group.publications).to match_array [p12_1, p12_2, p12_3]
        expect(p13_1.reload.duplicate_group).to be_nil
        expect(p13_2.reload.duplicate_group).to be_nil
        expect(p14_1.reload.duplicate_group.publications).to match_array [p14_1, p14_2, p14_3, p14_4]
        expect(p14_2.reload.duplicate_group.publications).to match_array [p14_1, p14_2, p14_3, p14_4]
        expect(p14_3.reload.duplicate_group.publications).to match_array [p14_1, p14_2, p14_3, p14_4]
        expect(p14_4.reload.duplicate_group.publications).to match_array [p14_1, p14_2, p14_3, p14_4]
        expect(p15_1.reload.duplicate_group.publications).to match_array [p15_1, p15_2]
        expect(p16_1.reload.duplicate_group.publications).to match_array [p16_1, p16_2]
      end
    end
  end

  describe '.group_duplicates_of' do
    context 'when given a publication with perfect matches' do
      let!(:p1) { create :publication,
                         title: 'Publication with an Exactly Duplicated Title',
                         published_on: Date.new(2000, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-123456789' }

      let!(:p2) { create :publication,
                         title: 'Publication with an Exactly Duplicated Title',
                         published_on: Date.new(2000, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-123456789' }

      let!(:p3) { create :publication,
                         title: 'Publication with an Exactly Duplicated Title',
                         published_on: Date.new(2000, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-123456789' }

      it 'groups the matching publications' do
        described_class.group_duplicates_of(p1)
        group = p1.reload.duplicate_group

        expect(p2.reload.duplicate_group).to eq group
        expect(p3.reload.duplicate_group).to eq group
      end
    end

    context 'when given a publication with perfect matches that has already been grouped' do
      let!(:p1) { create :publication,
                         title: 'Publication with an Exactly Duplicated Title',
                         published_on: Date.new(2000, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-123456789' }

      let!(:p2) { create :publication,
                         title: 'Publication with an Exactly Duplicated Title',
                         published_on: Date.new(2000, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-123456789' }

      let!(:p3) { create :publication,
                         title: 'Publication with an Exactly Duplicated Title',
                         published_on: Date.new(2000, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-123456789' }

      let!(:group) { create :duplicate_publication_group, publications: [p1, p2, p3] }

      it 'leaves the publications in the existing group' do
        described_class.group_duplicates_of(p1)

        expect(group.reload.publications).to match_array [p1, p2, p3]
      end
    end

    context 'given a publication that has a similar title to another publication and otherwise matches' do
      let!(:p1) { create :publication,
                         title: 'Multiple-Exponential Electron Injection in Ru(dcbpy)<sub>2</sub>(SCN)<sub>2</sub> Sensitized ZnO Nanocrystalline Thin Films',
                         published_on: Date.new(2000, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-987654321' }

      let!(:p2) { create :publication,
                         title: 'Multiple-exponential electron injection in Ru(dcbpy)(2)(SCN)(2) sensitized ZnO nanocrystalline thin films',
                         published_on: Date.new(2000, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-987654321' }

      it 'groups the publications' do
        described_class.group_duplicates_of(p1)
        group = p1.reload.duplicate_group

        expect(group).not_to be_nil
        expect(p2.reload.duplicate_group).to eq group
      end
    end

    context 'given a publication with a somewhat different title and the same publication date as another publication' do
      let!(:p1) { create :publication,
                         title: 'Utilizing cloud computing to address big geospatial data challenges',
                         published_on: Date.new(2000, 1, 1),
                         doi: nil }

      let!(:p2) { create :publication,
                         title: 'Utilizing cloud computing to do something entirely different with big data sets',
                         published_on: Date.new(2000, 1, 1),
                         doi: nil }

      it 'does not group the publications' do
        described_class.group_duplicates_of(p1)
        described_class.group_duplicates_of(p2)

        expect(p1.duplicate_group).to be_nil
        expect(p2.duplicate_group).to be_nil
      end
    end

    context 'given a publication with a similar titles to another publication and no other data' do
      let!(:p1) { create :publication,
                         title: 'Telomeric (TTAGGG)n sequences are associated with nucleolus organizer regions (NORs) in the wood lemming',
                         published_on: nil,
                         doi: nil }

      let!(:p2) { create :publication,
                         title: 'Telomeric (TTAGGG)(n) sequences are associated with nucleolus organizer regions (NORs) in the wood lemming',
                         published_on: nil,
                         doi: nil }

      it 'groups the publications' do
        described_class.group_duplicates_of(p1)
        group = p1.reload.duplicate_group

        expect(group).not_to be_nil
        expect(p2.reload.duplicate_group).to eq group
      end
    end

    context 'given a publication with a similar title to another publication and a different publication date that has the same year' do
      let!(:p1) { create :publication,
                         title: 'Observation and properties of the X(3872) decaying to J/ψπ<sup>+</sup>π<sup>-</sup> in pp̄ collisions at √s = 1.96 TeV',
                         published_on: Date.new(2000, 5, 20),
                         doi: nil }

      let!(:p2) { create :publication,
                         title: 'Observation and properties of the X(3872) decaying to J/psi pi(+)pi(-) in p(p)over-bar collisions at root s=1.96 TeV',
                         published_on: Date.new(2000, 1, 1),
                         doi: nil }

      it 'groups the publications' do
        described_class.group_duplicates_of(p1)
        group = p1.reload.duplicate_group

        expect(group).not_to be_nil
        expect(p2.reload.duplicate_group).to eq group
      end
    end

    context 'given a publication with the same title and publication date as another publication but with a different DOI' do
      let!(:p1) { create :publication,
                         title: 'A Really Generic Title',
                         published_on: Date.new(2000, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-23456431' }

      let!(:p2) { create :publication,
                         title: 'A Really Generic Title',
                         published_on: Date.new(2000, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-4563457245' }

      it 'does not group the publications' do
        described_class.group_duplicates_of(p1)
        described_class.group_duplicates_of(p2)

        expect(p1.duplicate_group).to be_nil
        expect(p2.duplicate_group).to be_nil
      end
    end

    context 'given a publication with the same title as another publication where only one has a DOI and publication date' do
      let!(:p1) { create :publication,
                         title: 'A Publication That Matches Another Publication',
                         published_on: Date.new(2000, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-22357534' }

      let!(:p2) { create :publication,
                         title: 'A Publication That Matches Another Publication',
                         published_on: nil,
                         doi: nil }

      it 'groups the publications' do
        described_class.group_duplicates_of(p1)
        group = p1.reload.duplicate_group

        expect(group).not_to be_nil
        expect(p2.reload.duplicate_group).to eq group
      end
    end

    context 'given a publication with the same title as another publication where the title is split between the two title fields' do
      let!(:p1) { create :publication,
                         title: "Assessing and investigating clinicians' research interests",
                         secondary_title: 'Lessons on expanding practices and data collection in a large practice research network',
                         published_on: nil,
                         doi: nil }

      let!(:p2) { create :publication,
                         title: "Assessing and investigating clinicians' research interests: Lessons on expanding practices and data collection in a large practice research network",
                         secondary_title: nil,
                         published_on: nil,
                         doi: nil }

      it 'groups the publications' do
        described_class.group_duplicates_of(p1)
        group = p1.reload.duplicate_group

        expect(group).not_to be_nil
        expect(p2.reload.duplicate_group).to eq group
      end

      context 'given the other publication' do
        it 'groups the publications' do
          described_class.group_duplicates_of(p2)
          group = p2.reload.duplicate_group

          expect(group).not_to be_nil
          expect(p1.reload.duplicate_group).to eq group
        end
      end
    end

    context 'given a publication that matches another publication but is in the same non-duplicate group' do
      let!(:p1) { create :publication,
                         title: 'Same as another publication but grouped as false-positive',
                         published_on: Date.new(1980, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-234623613' }

      let!(:p2) { create :publication,
                         title: 'Same as another publication but grouped as false-positive',
                         published_on: Date.new(1980, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-234623613' }

      let!(:ndpg) { create :non_duplicate_publication_group,
                           publications: [p1, p2] }

      it 'does not group the publications' do
        described_class.group_duplicates_of(p1)
        described_class.group_duplicates_of(p2)

        expect(p1.duplicate_group).to be_nil
        expect(p2.duplicate_group).to be_nil
      end
    end

    context 'given a publication that matches another publication that is in a different non-duplicate group' do
      let!(:p1) { create :publication,
                         title: 'In a different false-positive group from the match',
                         published_on: Date.new(1981, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-854537454' }

      let!(:p2) { create :publication,
                         title: 'In a different false-positive group from the match',
                         published_on: Date.new(1981, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-854537454' }

      let!(:other1) { create :publication, title: 'uquwegflkqulkuagekahkwehf' }
      let!(:other2) { create :publication, title: 'kvbkbcbebbcubibekubkubeuke' }

      let!(:ndpg1) { create :non_duplicate_publication_group,
                            publications: [p1, other1] }

      let!(:ndpg2) { create :non_duplicate_publication_group,
                            publications: [p2, other2] }

      it 'groups the publications' do
        described_class.group_duplicates_of(p1)
        group = p1.reload.duplicate_group

        expect(group).not_to be_nil
        expect(p2.reload.duplicate_group).to eq group
      end

      context 'given the other publication' do
        it 'groups the publications' do
          described_class.group_duplicates_of(p2)
          group = p2.reload.duplicate_group

          expect(group).not_to be_nil
          expect(p1.reload.duplicate_group).to eq group
        end
      end
    end

    context 'given a publication that matches two other publications that are both in the same non-duplicate group' do
      let!(:p1) { create :publication,
                         title: 'One in a group of three matching false-positives',
                         published_on: Date.new(1982, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-3463473' }

      let!(:p2) { create :publication,
                         title: 'One in a group of three matching false-positives',
                         published_on: Date.new(1982, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-3463473' }

      let!(:p3) { create :publication,
                         title: 'One in a group of three matching false-positives',
                         published_on: Date.new(1982, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-3463473' }

      let!(:ndpg) { create :non_duplicate_publication_group,
                           publications: [p1, p2, p3] }

      it 'does not group the publications' do
        described_class.group_duplicates_of(p1)
        described_class.group_duplicates_of(p2)
        described_class.group_duplicates_of(p3)

        expect(p1.duplicate_group).to be_nil
        expect(p2.duplicate_group).to be_nil
        expect(p3.duplicate_group).to be_nil
      end
    end

    context 'given a publication that matches two other publications where only one is in the same non-duplicate group' do
      let!(:p1) { create :publication,
                         title: 'Publication with a two matches where one might not be legit',
                         published_on: Date.new(1983, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-234534363' }

      let!(:p2) { create :publication,
                         title: 'Publication with a two matches where one might not be legit',
                         published_on: Date.new(1983, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-234534363' }

      let!(:p3) { create :publication,
                         title: 'Publication with a two matches where one might not be legit',
                         published_on: Date.new(1983, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-234534363' }

      let!(:ndpg) { create :non_duplicate_publication_group,
                           publications: [p1, p3] }

      it 'only groups the two that are not in the same non-duplicate group' do
        described_class.group_duplicates_of(p1)
        group = p1.reload.duplicate_group

        expect(p2.reload.duplicate_group).to eq group
        expect(p3.duplicate_group).to be_nil
      end
    end

    context 'given a publication that matches another publication where they both belong to two identical non-duplicate groups' do
      let!(:p1) { create :publication,
                         title: 'Publication in two identical false-positive groups with another publication',
                         published_on: Date.new(1984, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-956525657' }

      let!(:p2) { create :publication,
                         title: 'Publication in two identical false-positive groups with another publication',
                         published_on: Date.new(1984, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-956525657' }

      let!(:ndpg1) { create :non_duplicate_publication_group,
                            publications: [p1, p2] }
      let!(:ndpg2) { create :non_duplicate_publication_group,
                            publications: [p1, p2] }

      it 'does not group the publications' do
        described_class.group_duplicates_of(p1)
        described_class.group_duplicates_of(p2)

        expect(p1.duplicate_group).to be_nil
        expect(p2.duplicate_group).to be_nil
      end
    end

    context 'given a publication that matches other publications that are in different non-duplicate groups' do
      let!(:p1) { create :publication,
                         title: 'One of four matches in two different false-positive groups',
                         published_on: Date.new(1985, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-45782186' }

      let!(:p2) { create :publication,
                         title: 'One of four matches in two different false-positive groups',
                         published_on: Date.new(1985, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-45782186' }

      let!(:p3) { create :publication,
                         title: 'One of four matches in two different false-positive groups',
                         published_on: Date.new(1985, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-45782186' }

      let!(:p4) { create :publication,
                         title: 'One of four matches in two different false-positive groups',
                         published_on: Date.new(1985, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-45782186' }

      let!(:ndpg1) { create :non_duplicate_publication_group,
                            publications: [p1, p2] }
      let!(:ndpg2) { create :non_duplicate_publication_group,
                            publications: [p3, p4] }

      it 'groups only the publications that are not in the same non-duplicate group' do
        described_class.group_duplicates_of(p1)
        group = p1.reload.duplicate_group

        expect(group).not_to be_nil
        expect(p2.reload.duplicate_group).to be_nil
        expect(p3.reload.duplicate_group).to eq group
        expect(p4.reload.duplicate_group).to eq group
      end
    end

    context "given a publication with the same title as another publication that doesn't have a publication date and has a blank DOI" do
      let!(:p1) { create :publication,
                         title: 'A Perfect Title Match Where a DOI is blank',
                         published_on: Date.new(2000, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-22357534' }

      let!(:p2) { create :publication,
                         title: 'A Perfect Title Match Where a DOI is blank',
                         published_on: nil,
                         doi: '' }

      it 'groups the publications' do
        described_class.group_duplicates_of(p1)
        group = p1.reload.duplicate_group

        expect(group).not_to be_nil
        expect(p2.reload.duplicate_group).to eq group
      end
    end

    context 'given a publication that matches another publication except for DOI and the other has only an Activity Insight import' do
      let!(:p1) { create :publication,
                         title: "A match where there's a junk DOI from Activity Insight",
                         published_on: Date.new(1986, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-457472486' }

      let!(:p2) { create :publication,
                         title: "A match where there's a junk DOI from Activity Insight",
                         published_on: Date.new(1986, 1, 1),
                         doi: 'https://doi.org/10.000/junk' }

      let!(:p2_import_1) { create :publication_import,
                                  source: 'Activity Insight',
                                  publication: p2}

      it 'groups the publications' do
        described_class.group_duplicates_of(p2)
        group = p2.reload.duplicate_group

        expect(group).not_to be_nil
        expect(p1.reload.duplicate_group).to eq group
      end
    end

    context 'given a publication that matches another publication except for DOI and the other has both an Activity Insight import and a Pure import' do
      let!(:p1) { create :publication,
                         title: 'consider DOI because AI is not the only import',
                         published_on: Date.new(1987, 1, 1),
                         doi: 'https://doi.org/10.000/some-doi-457472486' }

      let!(:p2) { create :publication,
                         title: 'consider DOI because AI is not the only import',
                         published_on: Date.new(1987, 1, 1),
                         doi: 'https://doi.org/10.000/junk' }

      let!(:p2_import_1) { create :publication_import,
                                  source: 'Activity Insight',
                                  publication: p2}

      let!(:p2_import_2) { create :publication_import,
                                  source: 'Pure',
                                  publication: p2}

      it 'does not group the publications' do
        described_class.group_duplicates_of(p1)
        described_class.group_duplicates_of(p2)

        expect(p1.duplicate_group).to be_nil
        expect(p2.duplicate_group).to be_nil
      end
    end
  end

  describe '.group_publications' do
    let!(:pub1) { create :publication }

    context 'when given no publications' do
      it 'does not create any new duplicate publication groups' do
        expect { described_class.group_publications([]) }.not_to change(described_class, :count)
      end
    end

    context 'when given one publication' do
      it 'does not create any new duplicate publication groups' do
        expect { described_class.group_publications([pub1]) }.not_to change(described_class, :count)
      end
    end

    context 'when given multiple publications' do
      let!(:pub2) { create :publication }
      let!(:pub3) { create :publication }
      let!(:other_pub) { create :publication }
      let!(:existing_group1) { create :duplicate_publication_group }
      let!(:existing_group2) { create :duplicate_publication_group }
      let!(:grouped_pub1) { create :publication, duplicate_group: existing_group1 }
      let!(:grouped_pub2) { create :publication, duplicate_group: existing_group1 }
      let!(:grouped_pub3) { create :publication, duplicate_group: existing_group2 }
      let!(:grouped_pub4) { create :publication, duplicate_group: existing_group2 }

      context 'when none of the publications belong to a duplicate group' do
        it 'creates a new duplicate group' do
          expect { described_class.group_publications([pub1, pub2, pub3]) }.to change(described_class, :count).by 1
        end

        it 'adds each given publication to the group' do
          described_class.group_publications([pub1, pub2, pub3])

          new_group = pub1.reload.duplicate_group

          expect(new_group.publications).to match_array [pub1, pub2, pub3]
        end
      end

      context 'when one of the publications already belongs to a duplicate group' do
        it 'does not create any new duplicate publication groups' do
          expect { described_class.group_publications([pub1, pub2, grouped_pub1]) }.not_to change(described_class, :count)
        end

        it 'adds all of the given publications to the existing group' do
          described_class.group_publications([pub1, pub2, grouped_pub1])

          expect(existing_group1.reload.publications).to match_array [pub1, pub2, grouped_pub1, grouped_pub2]
        end
      end

      context 'when two of the given publications already belong to the same duplicate group' do
        it 'does not create any new duplicate publication groups' do
          expect { described_class.group_publications([pub2, grouped_pub1, grouped_pub2]) }.not_to change(described_class, :count)
        end

        it 'adds all of the given publications to the existing group' do
          described_class.group_publications([pub2, grouped_pub1, grouped_pub2])

          expect(existing_group1.reload.publications).to match_array [pub2, grouped_pub1, grouped_pub2]
        end
      end

      context 'when two of the given publications already belong to different duplicate groups' do
        it 'removes one of the existing duplicate groups' do
          expect { described_class.group_publications([pub2, grouped_pub1, grouped_pub3]) }.to change(described_class, :count).by -1
        end

        it 'adds all of the given publications and the other members of their groups to the remaining existing group' do
          described_class.group_publications([pub2, grouped_pub1, grouped_pub3])

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

  describe '.auto_merge' do
    let!(:group1) { create :duplicate_publication_group }
    let!(:group2) { create :duplicate_publication_group }
    let!(:group3) { create :duplicate_publication_group }

    let!(:group1_pub1) { create :publication, duplicate_group: group1, imports: group1_pub1_imports }
    let!(:group1_pub2) { create :publication, duplicate_group: group1, imports: group1_pub2_imports }

    let!(:group2_pub1) { create :publication, duplicate_group: group2, imports: group2_pub1_imports }
    let!(:group2_pub2) { create :publication, duplicate_group: group2, imports: group2_pub2_imports }

    let!(:group3_pub1) { create :publication, duplicate_group: group3, imports: group3_pub1_imports }
    let!(:group3_pub2) { create :publication, duplicate_group: group3, imports: group3_pub2_imports }

    let!(:group1_pub1_imports) { [group1_pub1_pure_import] }
    let!(:group1_pub2_imports) { [group1_pub2_ai_import] }

    let!(:group2_pub1_imports) { [group2_pub1_pure_import] }
    let!(:group2_pub2_imports) { [group2_pub2_ai_import] }

    let!(:group3_pub1_imports) { [group3_pub1_ai_import] }
    let!(:group3_pub2_imports) { [group3_pub2_ai_import] }

    let!(:group1_pub1_pure_import) { create(:publication_import, source: 'Pure') }
    let!(:group1_pub2_ai_import) { create(:publication_import, source: 'Activity Insight') }

    let!(:group2_pub1_pure_import) { create(:publication_import, source: 'Pure') }
    let!(:group2_pub2_ai_import) { create(:publication_import, source: 'Activity Insight') }

    let!(:group3_pub1_ai_import) { create(:publication_import, source: 'Activity Insight') }
    let!(:group3_pub2_ai_import) { create(:publication_import, source: 'Activity Insight') }

    it 'automatically merges applicable publications in each group' do
      described_class.auto_merge

      expect { group1.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { group2.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(group3.reload).to eq group3

      expect(group1_pub1.reload.imports).to match_array [group1_pub1_pure_import, group1_pub2_ai_import]
      expect { group1_pub2.reload }.to raise_error ActiveRecord::RecordNotFound

      expect(group2_pub1.reload.imports).to match_array [group2_pub1_pure_import, group2_pub2_ai_import]
      expect { group2_pub2.reload }.to raise_error ActiveRecord::RecordNotFound

      expect(group3.reload.publications).to match_array [group3_pub1, group3_pub2]
      expect(group3_pub1.reload.imports).to eq [group3_pub1_ai_import]
      expect(group3_pub2.reload.imports).to eq [group3_pub2_ai_import]
    end
  end

  describe '#publication_count' do
    let!(:dpg) { create :duplicate_publication_group }

    before { create_list :publication, 2, duplicate_group: dpg }

    it 'returns the number of publications that belong to the group' do
      expect(dpg.publication_count).to eq 2
    end
  end

  describe '#first_publication_title' do
    let!(:dpg) { create :duplicate_publication_group }

    context 'when the group has no publications' do
      it 'returns nil' do
        expect(dpg.first_publication_title).to be_nil
      end
    end

    context 'when the group has publications' do
      before do
        create :publication, duplicate_group: dpg, title: 'First Pub'
        create :publication, duplicate_group: dpg, title: 'Second Pub'
      end

      it 'returns the title of the first publication in the group' do
        expect(dpg.first_publication_title).to eq 'First Pub'
      end
    end
  end

  describe '#auto_merge' do
    let!(:group) { create :duplicate_publication_group }

    context 'when the group has no publications' do
      it 'does not change the number of publications in the database' do
        expect { group.auto_merge }.not_to change(Publication, :count)
      end

      it 'does not change the number of duplicate publication groups in the database' do
        expect { group.auto_merge }.not_to change(described_class, :count)
      end

      it 'does not delete the group' do
        group.auto_merge
        expect { group.reload }.not_to raise_error
      end

      it 'returns false' do
        expect(group.auto_merge).to be false
      end
    end

    context 'when the group has 1 publication' do
      let!(:pub) { create :publication, duplicate_group: group, imports: imports }

      context 'when the publication has no imports' do
        let(:imports) { [] }

        it 'does not change the number of publications in the database' do
          expect { group.auto_merge }.not_to change(Publication, :count)
        end

        it 'does not change the number of duplicate publication groups in the database' do
          expect { group.auto_merge }.not_to change(described_class, :count)
        end

        it 'does not delete the group' do
          group.auto_merge
          expect { group.reload }.not_to raise_error
        end

        it 'does not change the group membership' do
          group.auto_merge
          expect(group.reload.publications).to eq [pub]
        end

        it "does not change the member publication's imports" do
          group.auto_merge
          expect(pub.reload.imports).to eq []
        end

        it 'returns false' do
          expect(group.auto_merge).to be false
        end
      end

      context 'when the publication has an import from Pure' do
        let(:imports) { [pure_import] }
        let(:pure_import) { create(:publication_import, source: 'Pure') }

        it 'does not change the number of publications in the database' do
          expect { group.auto_merge }.not_to change(Publication, :count)
        end

        it 'does not change the number of duplicate publication groups in the database' do
          expect { group.auto_merge }.not_to change(described_class, :count)
        end

        it 'does not delete the group' do
          group.auto_merge
          expect { group.reload }.not_to raise_error
        end

        it 'does not change the group membership' do
          group.auto_merge
          expect(group.reload.publications).to eq [pub]
        end

        it "does not change the member publication's imports" do
          group.auto_merge
          expect(pub.reload.imports).to eq [pure_import]
          expect(pure_import.reload.auto_merged).to be_nil
        end

        it 'returns false' do
          expect(group.auto_merge).to be false
        end
      end

      context 'when the publication has an import from Activity Insight' do
        let(:imports) { [ai_import] }
        let(:ai_import) { create(:publication_import, source: 'Activity Insight') }

        it 'does not change the number of publications in the database' do
          expect { group.auto_merge }.not_to change(Publication, :count)
        end

        it 'does not change the number of duplicate publication groups in the database' do
          expect { group.auto_merge }.not_to change(described_class, :count)
        end

        it 'does not delete the group' do
          group.auto_merge
          expect { group.reload }.not_to raise_error
        end

        it 'does not change the group membership' do
          group.auto_merge
          expect(group.reload.publications).to eq [pub]
        end

        it "does not change the member publication's imports" do
          group.auto_merge
          expect(pub.reload.imports).to eq [ai_import]
          expect(ai_import.reload.auto_merged).to be_nil
        end

        it 'returns false' do
          expect(group.auto_merge).to be false
        end
      end
    end

    context 'when the group has 2 publications' do
      let!(:pub1) { create :publication, title: 'A Generic Title', duplicate_group: group, imports: pub1_imports }
      let!(:pub2) { create :publication, title: 'The Generic Title', duplicate_group: group, imports: pub2_imports }

      context 'when both of the publications have no imports' do
        let(:pub1_imports) { [] }
        let(:pub2_imports) { [] }

        it 'does not change the number of publications in the database' do
          expect { group.auto_merge }.not_to change(Publication, :count)
        end

        it 'does not change the number of duplicate publication groups in the database' do
          expect { group.auto_merge }.not_to change(described_class, :count)
        end

        it 'does not delete the group' do
          group.auto_merge
          expect { group.reload }.not_to raise_error
        end

        it 'does not change the group membership' do
          group.auto_merge
          expect(group.reload.publications).to match_array [pub1, pub2]
        end

        it 'returns false' do
          expect(group.auto_merge).to be false
        end
      end

      context 'when both of the publications only have an import from Pure' do
        let(:pub1_imports) { [pure_import1] }
        let(:pub2_imports) { [pure_import2] }
        let(:pure_import1) { create(:publication_import, source: 'Pure') }
        let(:pure_import2) { create(:publication_import, source: 'Pure') }

        it 'does not change the number of publications in the database' do
          expect { group.auto_merge }.not_to change(Publication, :count)
        end

        it 'does not change the number of duplicate publication groups in the database' do
          expect { group.auto_merge }.not_to change(described_class, :count)
        end

        it 'does not delete the group' do
          group.auto_merge
          expect { group.reload }.not_to raise_error
        end

        it 'does not change the group membership' do
          group.auto_merge
          expect(group.reload.publications).to match_array [pub1, pub2]
        end

        it "does not change the member publications' imports" do
          group.auto_merge
          expect(pub1.reload.imports).to eq [pure_import1]
          expect(pure_import1.reload.auto_merged).to be_nil
          expect(pub2.reload.imports).to eq [pure_import2]
          expect(pure_import2.reload.auto_merged).to be_nil
        end

        it 'returns false' do
          expect(group.auto_merge).to be false
        end
      end

      context 'when both of the publications only have an import from Activity Insight' do
        let(:pub1_imports) { [ai_import1] }
        let(:pub2_imports) { [ai_import2] }
        let(:ai_import1) { create(:publication_import, source: 'Activity Insight') }
        let(:ai_import2) { create(:publication_import, source: 'Activity Insight') }

        it 'does not change the number of publications in the database' do
          expect { group.auto_merge }.not_to change(Publication, :count)
        end

        it 'does not change the number of duplicate publication groups in the database' do
          expect { group.auto_merge }.not_to change(described_class, :count)
        end

        it 'does not delete the group' do
          group.auto_merge
          expect { group.reload }.not_to raise_error
        end

        it 'does not change the group membership' do
          group.auto_merge
          expect(group.reload.publications).to match_array [pub1, pub2]
        end

        it "does not change the member publications' imports" do
          group.auto_merge
          expect(pub1.reload.imports).to eq [ai_import1]
          expect(ai_import1.reload.auto_merged).to be_nil
          expect(pub2.reload.imports).to eq [ai_import2]
          expect(ai_import2.reload.auto_merged).to be_nil
        end

        it 'returns false' do
          expect(group.auto_merge).to be false
        end
      end

      
      context 'when one publication has only an import from Activity Insight and the other has only an import from Pure and titles are similar' do
        let(:pub1_imports) { [ai_import] }
        let(:pub2_imports) { [pure_import] }
        let(:ai_import) { create(:publication_import, source: 'Activity Insight') }
        let(:pure_import) { create(:publication_import, source: 'Pure') }

        it 'deletes the Activity Insight publication' do
          expect { group.auto_merge }.to change(Publication, :count).by -1
          expect { pub1.reload }.to raise_error ActiveRecord::RecordNotFound
        end

        it 'deletes the group' do
          expect { group.auto_merge }.to change(described_class, :count).by -1
          expect { group.reload }.to raise_error ActiveRecord::RecordNotFound
        end

        it "reassigns the Activity Insight publication's import to the Pure publication" do
          group.auto_merge
          expect(pub2.reload.imports).to match_array [ai_import, pure_import]
        end

        it "does not mark the Pure publication's import as having been auto merged" do
          group.auto_merge
          expect(pure_import.reload.auto_merged).to be_nil
        end

        it "marks the Activity Insight publication's import as having been auto merged" do
          group.auto_merge
          expect(ai_import.reload.auto_merged).to be true
        end

        it 'returns true' do
          expect(group.auto_merge).to be true
        end
      end
    end

    context 'when one publication has only an import from Activity Insight and the other has only an import from Pure and titles are not similar' do
      let!(:pub1) { create :publication, title: 'A Generic Title', duplicate_group: group, imports: pub1_imports }
      let!(:pub2) { create :publication, title: 'Something Different', duplicate_group: group, imports: pub2_imports }
      let(:pub1_imports) { [ai_import] }
      let(:pub2_imports) { [pure_import] }
      let(:ai_import) { create(:publication_import, source: 'Activity Insight') }
      let(:pure_import) { create(:publication_import, source: 'Pure') }

      it 'does not change the number of publications in the database' do
        expect { group.auto_merge }.not_to change(Publication, :count)
      end

      it 'does not change the number of duplicate publication groups in the database' do
        expect { group.auto_merge }.not_to change(described_class, :count)
      end

      it 'does not delete the group' do
        group.auto_merge
        expect { group.reload }.not_to raise_error
      end

      it 'does not change the group membership' do
        group.auto_merge
        expect(group.reload.publications).to match_array [pub1, pub2]
      end

      it "does not change the member publications' imports" do
        group.auto_merge
        expect(pub1.reload.imports).to eq [ai_import]
        expect(ai_import.reload.auto_merged).to be_nil
        expect(pub2.reload.imports).to eq [pure_import]
        expect(pure_import.reload.auto_merged).to be_nil
      end

      it 'returns false' do
        expect(group.auto_merge).to be false
      end
    end

    context 'when the group has 3 publications' do
      let!(:pub1) { create :publication, duplicate_group: group, imports: pub1_imports }
      let!(:pub2) { create :publication, duplicate_group: group, imports: pub2_imports }
      let!(:pub3) { create :publication, duplicate_group: group, imports: pub3_imports }

      context 'when one publication has only an import from Activity Insight and another has only an import from Pure' do
        let(:pub1_imports) { [ai_import] }
        let(:pub2_imports) { [pure_import] }
        let(:pub3_imports) { [ai_import2] }
        let(:ai_import) { create(:publication_import, source: 'Activity Insight') }
        let(:ai_import2) { create(:publication_import, source: 'Activity Insight') }
        let(:pure_import) { create(:publication_import, source: 'Pure') }

        it 'does not change the number of publications in the database' do
          expect { group.auto_merge }.not_to change(Publication, :count)
        end

        it 'does not change the number of duplicate publication groups in the database' do
          expect { group.auto_merge }.not_to change(described_class, :count)
        end

        it 'does not delete the group' do
          group.auto_merge
          expect { group.reload }.not_to raise_error
        end

        it 'does not change the group membership' do
          group.auto_merge
          expect(group.reload.publications).to match_array [pub1, pub2, pub3]
        end

        it "does not change the member publications' imports" do
          group.auto_merge
          expect(pub1.reload.imports).to eq [ai_import]
          expect(ai_import.reload.auto_merged).to be_nil
          expect(pub2.reload.imports).to eq [pure_import]
          expect(pure_import.reload.auto_merged).to be_nil
          expect(pub3.reload.imports).to eq [ai_import2]
          expect(ai_import2.reload.auto_merged).to be_nil
        end

        it 'returns false' do
          expect(group.auto_merge).to be false
        end
      end
    end
  end

  describe '#auto_merge_on_doi' do
    let!(:group) { create :duplicate_publication_group }

    context 'when the group has no publications' do
      it 'does not change the number of publications in the database' do
        expect { group.auto_merge_on_doi }.not_to change(Publication, :count)
      end

      it 'does not change the number of duplicate publication groups in the database' do
        expect { group.auto_merge_on_doi }.not_to change(described_class, :count)
      end

      it 'does not delete the group' do
        group.auto_merge_on_doi
        expect { group.reload }.not_to raise_error
      end
    end

    context 'when the group has 1 publication' do
      let!(:pub) { create :publication, duplicate_group: group }

      it 'does not change the number of publications in the database' do
        expect { group.auto_merge_on_doi }.not_to change(Publication, :count)
      end

      it 'does not change the number of duplicate publication groups in the database' do
        expect { group.auto_merge_on_doi }.not_to change(described_class, :count)
      end

      it 'does not delete the group' do
        group.auto_merge_on_doi
        expect { group.reload }.not_to raise_error
      end

      it 'does not change the group membership' do
        group.auto_merge_on_doi
        expect(group.reload.publications).to eq [pub]
      end

      it "does not change the member publication's imports" do
        group.auto_merge_on_doi
        expect(pub.reload.imports).to eq []
      end
    end

    context 'when the group has 2 publications' do
      let!(:pub1) { create :sample_publication, duplicate_group: group }
      let!(:pub2) do
        Publication.create(pub1
          .attributes
          .delete_if { |key, _value| key == 'id' })
      end
      let!(:import1) { create :publication_import, publication: pub1 }
      let!(:import2) { create :publication_import, publication: pub2 }

      context 'when PublicationMatchOnDoiPolicy returns true for these publications' do
        it 'deletes one publication' do
          expect { group.auto_merge_on_doi }.to change(Publication, :count).by -1
        end

        it 'deletes the group' do
          expect { group.auto_merge_on_doi }.to change(described_class, :count).by -1
          expect { group.reload }.to raise_error ActiveRecord::RecordNotFound
        end

        it "marks one publication's import as having been auto merged" do
          group.auto_merge_on_doi
          expect([import1.reload.auto_merged, import2.reload.auto_merged].compact).to eq [true]
        end
      end
    end

    context 'when the group has 3 publications' do
      let!(:pub1) { create :sample_publication, duplicate_group: group }
      let!(:pub2) do
        Publication.create(pub1
                               .attributes
                               .delete_if { |key, _value| key == 'id' })
      end
      let!(:pub3) { create :sample_publication, duplicate_group: group }

      context 'when PublicationMatchOnDoiPolicy returns true for only two of publications' do
        it 'deletes one publication' do
          expect { group.auto_merge_on_doi }.to change(Publication, :count).by -1
        end

        it 'does not delete the group' do
          expect { group.auto_merge_on_doi }.not_to change(described_class, :count)
        end
      end
    end
  end
end
