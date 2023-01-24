# frozen_string_literal: true

require 'component/component_spec_helper'

describe UserProfile do
  subject(:profile) { described_class.new(user) }

  let!(:user) { create(:user,
                       webaccess_id: 'abc123',
                       ai_title: 'ai test title',
                       ai_website: 'www.test.com',
                       ai_bio: 'test bio',
                       show_all_publications: true,
                       show_all_contracts: true,
                       ai_teaching_interests: 'test teaching interests',
                       ai_research_interests: 'test research interests') }

  let(:piu_service) { class_double(PsuIdentityUserService).as_stubbed_const }

  before do
    allow(piu_service).to receive(:find_or_initialize_user)
  end

  it { is_expected.to delegate_method(:active?).to(:user) }
  it { is_expected.to delegate_method(:available_deputy?).to(:user) }
  it { is_expected.to delegate_method(:id).to(:user) }
  it { is_expected.to delegate_method(:name).to(:user) }
  it { is_expected.to delegate_method(:office_location).to(:user) }
  it { is_expected.to delegate_method(:office_phone_number).to(:user) }
  it { is_expected.to delegate_method(:orcid_identifier).to(:user) }
  it { is_expected.to delegate_method(:organization_name).to(:user) }
  it { is_expected.to delegate_method(:pure_profile_url).to(:user) }
  it { is_expected.to delegate_method(:scopus_h_index).to(:user) }
  it { is_expected.to delegate_method(:total_scopus_citations).to(:user) }

  describe '::new' do
    context 'when the user has data from the identity management service' do
      let(:user) { build(:user, :with_psu_identity) }

      it 'does NOT update their identity' do
        described_class.new(user)
        expect(piu_service).not_to have_received(:find_or_initialize_user)
      end
    end

    context 'when the user has not updated their identity data' do
      let(:user) { build(:user) }

      it 'updates their identity' do
        described_class.new(user)
        expect(piu_service).to have_received(:find_or_initialize_user)
      end
    end
  end

  describe '#title' do
    context 'when ai_title is present for user' do
      it "returns the given user's title from Activity Insight" do
        expect(profile.title).to eq 'ai test title'
      end
    end

    context 'when ai_title is not present for user but multiple organization position_title from Pure are' do
      let!(:user_organization_membership1) do
        create(:user_organization_membership, user: user, started_on: 1.week.ago, position_title: 'Title 1')
      end
      let!(:user_organization_membership2) do
        create(:user_organization_membership, user: user, started_on: 1.day.ago, position_title: 'Title 2')
      end

      before do
        user.update ai_title: nil
        user.save!
      end

      context 'when one of the postition titles is `primary`' do
        before do
          user_organization_membership1.update primary: true
        end

        it "returns the given user's title from Pure" do
          expect(profile.title).to eq user_organization_membership1.position_title
        end
      end

      context 'when no postion_title is `primary`' do
        it 'returns the most recent position title' do
          expect(profile.title).to eq user_organization_membership2.position_title
        end
      end
    end
  end

  describe '#email' do
    it 'returns the email address for the given user based on their webaccess ID' do
      expect(profile.email).to eq 'abc123@psu.edu'
    end
  end

  describe '#personal_website' do
    it "returns the given user's personal website information from Activity Insight" do
      expect(profile.personal_website).to eq 'www.test.com'
    end
  end

  describe '#bio' do
    it "returns the given user's biographical text from Activity Insight" do
      expect(profile.bio).to eq 'test bio'
    end
  end

  describe '#teaching_interests' do
    it "returns the given user's teaching interests from Activity Insight" do
      expect(profile.teaching_interests).to eq 'test teaching interests'
    end
  end

  describe '#research_interests' do
    it "returns the given user's research interests from Activity Insight" do
      expect(profile.research_interests).to eq 'test research interests'
    end
  end

  describe '#publications' do
    let!(:other_user) { create(:user) }
    let!(:pub1) { create(:publication, title: 'First Publication',
                                       visible: true,
                                       journal_title: 'Test Journal',
                                       published_on: Date.new(2010, 1, 1),
                                       total_scopus_citations: 4) }
    let!(:pub2) { create(:publication, title: 'Second Publication',
                                       visible: true,
                                       publisher_name: 'Test Publisher',
                                       published_on: Date.new(2015, 1, 1)) }
    let!(:pub3) { create(:publication, title: 'Third Publication',
                                       visible: true,
                                       published_on: Date.new(2018, 1, 1),
                                       total_scopus_citations: 5) }
    let!(:pub4) { create(:publication, title: 'Undated Publication',
                                       visible: true) }
    let!(:pub5) { create(:publication,
                         title: 'Invisible Publication',
                         visible: false) }
    let!(:pub6) { create(:publication, title: 'Hidden Authorship Publication',
                                       visible: true) }
    let!(:pub7) { create(:publication, title: 'Unconfirmed Publication',
                                       visible: true) }
    let!(:pub8) { create(:publication,
                         title: 'Non-Journal-Article Publication',
                         visible: true,
                         publication_type: 'Book') }
    let(:pos1) { nil }
    let(:pos2) { nil }
    let(:pos3) { nil }
    let(:pos4) { nil }
    let(:pos5) { nil }
    let(:pos6) { nil }

    before do
      create(:authorship, user: user, publication: pub1, position_in_profile: pos1)
      create(:authorship, user: user, publication: pub2, position_in_profile: pos2)
      create(:authorship, user: user, publication: pub3, position_in_profile: pos3)
      create(:authorship, user: user, publication: pub4, position_in_profile: pos4)
      create(:authorship, user: user, publication: pub5, position_in_profile: pos5)
      create(:authorship, user: user, publication: pub6, position_in_profile: pos6, visible_in_profile: false)
      create(:authorship, user: user, publication: pub7, confirmed: false)
      create(:authorship, user: user, publication: pub8)

      create(:authorship, user: other_user, publication: pub1)
    end

    context "when none of the user's authorships have a profile position" do
      it "returns an array of strings describing the given user's publications in order by date" do
        expect(profile.publications).to eq [
          '<span class="publication-title">Undated Publication</span>',
          '<span class="publication-title">Third Publication</span>, 2018',
          '<span class="publication-title">Second Publication</span>, <span class="journal-name">Test Publisher</span>, 2015',
          '<span class="publication-title">First Publication</span>, <span class="journal-name">Test Journal</span>, 2010'
        ]
      end

      context 'when a publication has an open access URL' do
        before { pub1.update_attribute(:open_access_locations, [build(:open_access_location,
                                                                      source: Source::SCHOLARSPHERE,
                                                                      url: 'https://example.org/pubs/1')]) }

        it "returns that publication's title as a link to the URL" do
          expect(profile.publications).to eq [
            '<span class="publication-title">Undated Publication</span>',
            '<span class="publication-title">Third Publication</span>, 2018',
            '<span class="publication-title">Second Publication</span>, <span class="journal-name">Test Publisher</span>, 2015',
            '<span class="publication-title"><a href="https://example.org/pubs/1" target="_blank">First Publication</a></span>, <span class="journal-name">Test Journal</span>, 2010'
          ]
        end
      end
    end

    context "when one of the user's authorships has a profile position set" do
      let(:pos2) { 1 }

      it "returns an array of strings describing the given user's publications in order first by position, then by date" do
        expect(profile.publications).to eq [
          '<span class="publication-title">Undated Publication</span>',
          '<span class="publication-title">Third Publication</span>, 2018',
          '<span class="publication-title">First Publication</span>, <span class="journal-name">Test Journal</span>, 2010',
          '<span class="publication-title">Second Publication</span>, <span class="journal-name">Test Publisher</span>, 2015'
        ]
      end
    end

    context "when all of the user's authorships have profile positions set" do
      let(:pos1) { 5 }
      let(:pos2) { 3 }
      let(:pos3) { 2 }
      let(:pos4) { 6 }
      let(:pos5) { 4 }
      let(:pos6) { 1 }

      it "returns an array of strings describing the given user's publications in order by position" do
        expect(profile.publications).to eq [
          '<span class="publication-title">Third Publication</span>, 2018',
          '<span class="publication-title">Second Publication</span>, <span class="journal-name">Test Publisher</span>, 2015',
          '<span class="publication-title">First Publication</span>, <span class="journal-name">Test Journal</span>, 2010',
          '<span class="publication-title">Undated Publication</span>'
        ]
      end
    end
  end

  describe '#publication_records' do
    let!(:user2) { create(:user) }
    let!(:pub1) { create(:publication,
                         title: 'First Publication',
                         visible: true,
                         published_on: Date.new(2010, 1, 1)) }
    let!(:pub2) { create(:publication,
                         title: 'Second Publication',
                         visible: true,
                         published_on: Date.new(2015, 1, 1)) }
    let!(:pub3) { create(:publication,
                         title: 'Third Publication',
                         visible: true,
                         published_on: Date.new(2018, 1, 1)) }
    let!(:pub4) { create(:publication,
                         title: 'Undated Publication',
                         visible: true) }
    let!(:pub5) { create(:publication,
                         title: 'Invisible Publication',
                         visible: false) }
    let!(:pub6) { create(:publication,
                         title: 'Unconfirmed, Claimed Publication',
                         visible: true,
                         published_on: Date.new(2000, 1, 1)) }
    let!(:pub7) { create(:publication,
                         title: 'Non-Journal-Article Publication',
                         visible: true,
                         publication_type: 'Book') }
    let!(:pub8) { create(:publication,
                         title: 'Unconfirmed, Unclaimed Publication',
                         visible: true) }
    let(:pos1) { nil }
    let(:pos2) { nil }
    let(:pos3) { nil }
    let(:pos4) { nil }
    let(:pos5) { nil }
    let(:pos6) { nil }

    before do
      create(:authorship, user: user2, publication: pub1)
      create(:authorship, user: user, publication: pub1, position_in_profile: pos1)
      create(:authorship, user: user, publication: pub2, position_in_profile: pos2)
      create(:authorship, user: user, publication: pub3, position_in_profile: pos3)
      create(:authorship, user: user, publication: pub4, position_in_profile: pos4)
      create(:authorship, user: user, publication: pub5, position_in_profile: pos5)
      create(:authorship,
             user: user,
             publication: pub6,
             position_in_profile: pos6,
             confirmed: false,
             claimed_by_user: true)
      create(:authorship, user: user, publication: pub7)
      create(:authorship, user: user, publication: pub8, confirmed: false, claimed_by_user: false)
    end

    context "when none of the user's authorships have a profile position" do
      it "returns the given user's publications in order by date" do
        expect(profile.publication_records).to eq [pub4, pub3, pub2, pub1, pub6]
      end
    end

    context "when one of the user's authorships has a profile position set" do
      let(:pos2) { 1 }

      it "returns the given user's publications in order first by position, then by date" do
        expect(profile.publication_records).to eq [pub4, pub3, pub1, pub6, pub2]
      end
    end

    context "when all of the user's authorships have profile positions set" do
      let(:pos1) { 5 }
      let(:pos2) { 3 }
      let(:pos3) { 2 }
      let(:pos4) { 6 }
      let(:pos5) { 4 }
      let(:pos6) { 1 }

      it "returns the given user's publications in order by position" do
        expect(profile.publication_records).to eq [pub6, pub3, pub2, pub1, pub4]
      end
    end
  end

  describe '#public_publication_records' do
    let!(:user2) { create(:user) }
    let!(:pub1) { create(:publication,
                         title: 'First Publication',
                         visible: true,
                         published_on: Date.new(2010, 1, 1)) }
    let!(:pub2) { create(:publication,
                         title: 'Second Publication',
                         visible: true,
                         published_on: Date.new(2015, 1, 1)) }
    let!(:pub3) { create(:publication,
                         title: 'Third Publication',
                         visible: true,
                         published_on: Date.new(2018, 1, 1)) }
    let!(:pub4) { create(:publication,
                         title: 'Undated Publication',
                         visible: true) }
    let!(:pub5) { create(:publication,
                         title: 'Invisible Publication',
                         visible: false) }
    let!(:pub6) { create(:publication,
                         title: 'Unconfirmed Publication',
                         visible: true) }
    let!(:pub7) { create(:publication,
                         title: 'Non-Journal-Article Publication',
                         visible: true,
                         publication_type: 'Book') }
    let(:pos1) { nil }
    let(:pos2) { nil }
    let(:pos3) { nil }
    let(:pos4) { nil }
    let(:pos5) { nil }

    before do
      create(:authorship, user: user2, publication: pub1)
      create(:authorship, user: user, publication: pub1, position_in_profile: pos1)
      create(:authorship, user: user, publication: pub2, position_in_profile: pos2)
      create(:authorship, user: user, publication: pub3, position_in_profile: pos3)
      create(:authorship, user: user, publication: pub4, position_in_profile: pos4)
      create(:authorship, user: user, publication: pub5, position_in_profile: pos5)
      create(:authorship, user: user, publication: pub6, confirmed: false)
      create(:authorship, user: user, publication: pub7)
    end

    context "when none of the user's authorships have a profile position" do
      it "returns the given user's publications in order by date" do
        expect(profile.public_publication_records).to eq [pub4, pub3, pub2, pub1]
      end
    end

    context "when one of the user's authorships has a profile position set" do
      let(:pos2) { 1 }

      it "returns the given user's publications in order first by position, then by date" do
        expect(profile.public_publication_records).to eq [pub4, pub3, pub1, pub2]
      end
    end

    context "when all of the user's authorships have profile positions set" do
      let(:pos1) { 5 }
      let(:pos2) { 3 }
      let(:pos3) { 2 }
      let(:pos4) { 6 }
      let(:pos5) { 4 }

      it "returns the given user's publications in order by position" do
        expect(profile.public_publication_records).to eq [pub3, pub2, pub1, pub4]
      end
    end
  end

  describe '#other_publications' do
    let!(:pub1) { create(:publication, title: 'First Publication',
                                       publication_type: 'Letter',
                                       visible: true,
                                       journal_title: 'Test Journal',
                                       published_on: Date.new(2010, 1, 1)) }
    let!(:pub2) { create(:publication, title: 'Second Publication',
                                       publication_type: 'Book',
                                       visible: true,
                                       publisher_name: 'Test Publisher',
                                       published_on: Date.new(2015, 1, 1)) }
    let!(:pub3) { create(:publication, title: 'Third Publication',
                                       publication_type: 'Book',
                                       visible: true,
                                       publisher_name: 'Test Publisher',
                                       published_on: Date.new(2016, 1, 1)) }

    before do
      create(:authorship, user: user, publication: pub1, position_in_profile: nil)
      create(:authorship, user: user, publication: pub2, position_in_profile: 2)
      create(:authorship, user: user, publication: pub3, position_in_profile: 1)
    end

    it "returns a hash of arrays of strings describing the given user's non-article publications in order by position" do
      expect(profile.other_publications).to eq({
                                                 'Books' => [
                                                   '<span class="publication-title">Third Publication</span>, <span class="journal-name">Test Publisher</span>, 2016',
                                                   '<span class="publication-title">Second Publication</span>, <span class="journal-name">Test Publisher</span>, 2015'
                                                 ],
                                                 'Letters' => [
                                                   '<span class="publication-title">First Publication</span>, <span class="journal-name">Test Journal</span>, 2010'
                                                 ]
                                               })
    end
  end

  describe '#other_publication_records' do
    let!(:pub1) { create(:publication, title: 'First Publication',
                                       publication_type: 'Letter',
                                       visible: true,
                                       journal_title: 'Test Journal',
                                       published_on: Date.new(2010, 1, 1)) }
    let!(:pub2) { create(:publication, title: 'Second Publication',
                                       publication_type: 'Book',
                                       visible: true,
                                       publisher_name: 'Test Publisher',
                                       published_on: Date.new(2015, 1, 1)) }
    let!(:pub3) { create(:publication, title: 'Third Publication',
                                       publication_type: 'Book',
                                       visible: true,
                                       publisher_name: 'Test Publisher',
                                       published_on: Date.new(2016, 1, 1)) }

    before do
      create(:authorship, user: user, publication: pub1, position_in_profile: nil)
      create(:authorship, user: user, publication: pub2, position_in_profile: 2)
      create(:authorship, user: user, publication: pub3, position_in_profile: 1)
    end

    it "returns an array of strings describing the given user's non-article publications in order by position" do
      expect(profile.other_publication_records).to eq [pub1, pub3, pub2]
    end
  end

  describe '#grants' do
    context 'when the user has no grants' do
      it 'returns an empty array' do
        expect(profile.grants).to eq []
      end
    end

    context 'when the user has grants' do
      let!(:grant1) { create(:grant,
                             title: 'Grant 1',
                             agency_name: 'National Science Foundation',
                             start_date: Date.new(1980, 1, 1),
                             end_date: Date.new(1990, 2, 2)) }
      let!(:grant2) { create(:grant,
                             identifier: 'Grant 2',
                             wos_agency_name: 'Agency 2',
                             start_date: Date.new(1985, 1, 1),
                             end_date: Date.new(1986, 2, 2)) }
      let!(:grant3) { create(:grant,
                             wos_identifier: 'Grant 3',
                             agency_name: 'National Science Foundation',
                             start_date: Date.new(2000, 1, 1),
                             end_date: Date.new(2002, 2, 2)) }
      let!(:grant4) { create(:grant,
                             title: 'Grant 4',
                             agency_name: 'National Science Foundation',
                             start_date: Date.new(1990, 1, 1),
                             end_date: nil) }
      let!(:grant5) { create(:grant,
                             title: 'Grant 5',
                             agency_name: 'National Science Foundation',
                             start_date: nil,
                             end_date: nil) }
      let!(:grant6) { create(:grant,
                             title: 'Grant 6',
                             agency_name: 'National Science Foundation',
                             start_date: Date.new(2010, 1, 1),
                             end_date: Date.new(2015, 2, 2)) }

      before do
        create(:researcher_fund, grant: grant1, user: user)
        create(:researcher_fund, grant: grant2, user: user)
        create(:researcher_fund, grant: grant3, user: user)
        create(:researcher_fund, grant: grant4, user: user)
        create(:researcher_fund, grant: grant5, user: user)
        create(:researcher_fund, grant: grant6, user: user)
      end

      it 'returns an array of strings describing the grants in order by date' do
        expect(profile.grants).to eq [
          'Grant 6, National Science Foundation, 1/2010 - 2/2015',
          'Grant 3, National Science Foundation, 1/2000 - 2/2002',
          'Grant 4, National Science Foundation',
          'Grant 2, Agency 2, 1/1985 - 2/1986',
          'Grant 1, National Science Foundation, 1/1980 - 2/1990',
          'Grant 5, National Science Foundation'
        ]
      end
    end
  end

  describe '#presentations' do
    let!(:pres1) { create(:presentation,
                          name: 'Presentation Two',
                          organization: 'An Organization',
                          location: 'Earth',
                          visible: true) }
    let!(:pres2) { create(:presentation,
                          title: nil,
                          name: nil,
                          visible: true) }
    let!(:pres3) { create(:presentation,
                          name: 'Presentation Three',
                          organization: 'Org',
                          location: 'Here',
                          visible: false) }
    let!(:pres4) { create(:presentation,
                          title: '',
                          name: '',
                          visible: true) }
    let!(:pres5) { create(:presentation,
                          title: 'Presentation Four',
                          visible: true) }
    let!(:pres6) { create(:presentation,
                          title: 'Presentation Five',
                          visible: true) }
    let!(:pres7) { create(:presentation,
                          title: 'Presentation Six',
                          visible: true) }

    before do
      create(:presentation_contribution,
             user: user,
             presentation: pres1,
             visible_in_profile: true,
             position_in_profile: 2)
      create(:presentation_contribution,
             user: user,
             presentation: pres2,
             visible_in_profile: true,
             position_in_profile: nil)
      create(:presentation_contribution,
             user: user,
             presentation: pres3,
             visible_in_profile: true,
             position_in_profile: nil)
      create(:presentation_contribution,
             user: user,
             presentation: pres5,
             visible_in_profile: false,
             position_in_profile: nil)
      create(:presentation_contribution,
             user: user,
             presentation: pres6,
             visible_in_profile: true,
             position_in_profile: nil)
      create(:presentation_contribution,
             user: user,
             presentation: pres7,
             visible_in_profile: true,
             position_in_profile: 1)
    end

    it "returns an array of strings describing the given user's visible presentations in order by user preference" do
      expect(profile.presentations).to eq ['Presentation Five',
                                           'Presentation Six',
                                           'Presentation Two, An Organization, Earth']
    end
  end

  describe '#presentation_records' do
    let!(:other_user) { create(:user) }
    let!(:pres1) { create(:presentation,
                          name: 'Presentation Two',
                          organization: 'An Organization',
                          location: 'Earth',
                          visible: true) }
    let!(:pres2) { create(:presentation,
                          title: nil,
                          name: nil,
                          visible: true) }
    let!(:pres3) { create(:presentation,
                          name: 'Presentation Three',
                          organization: 'Org',
                          location: 'Here',
                          visible: false) }
    let!(:pres4) { create(:presentation,
                          title: '',
                          name: '',
                          visible: true) }
    let!(:pres5) { create(:presentation,
                          title: 'Presentation Four',
                          visible: true) }
    let!(:pres6) { create(:presentation,
                          title: 'Presentation Five',
                          visible: true) }
    let!(:pres7) { create(:presentation,
                          title: 'Presentation Six',
                          visible: true) }

    before do
      create(:presentation_contribution,
             user: other_user,
             presentation: pres1,
             visible_in_profile: true)
      create(:presentation_contribution,
             user: user,
             presentation: pres1,
             visible_in_profile: true,
             position_in_profile: 2)
      create(:presentation_contribution,
             user: user,
             presentation: pres2,
             visible_in_profile: true,
             position_in_profile: nil)
      create(:presentation_contribution,
             user: user,
             presentation: pres3,
             visible_in_profile: true,
             position_in_profile: nil)
      create(:presentation_contribution,
             user: user,
             presentation: pres5,
             visible_in_profile: false,
             position_in_profile: 3)
      create(:presentation_contribution,
             user: user,
             presentation: pres6,
             visible_in_profile: true,
             position_in_profile: nil)
      create(:presentation_contribution,
             user: user,
             presentation: pres7,
             visible_in_profile: true,
             position_in_profile: 1)
    end

    it "returns an array of the given user's visible presentations in order by user preference" do
      expect(profile.presentation_records).to eq [pres6, pres7, pres1, pres5]
    end
  end

  describe '#performances' do
    let!(:perf1) { create(:performance,
                          title: 'Performance One',
                          location: 'Location One',
                          start_on: Date.new(2017, 1, 1)) }
    let!(:perf2) { create(:performance,
                          title: 'Performance Two',
                          location: nil,
                          start_on: Date.new(2016, 1, 1)) }
    let!(:perf3) { create(:performance,
                          title: 'Performance Three',
                          location: 'Location Three',
                          start_on: nil) }
    let!(:perf4) { create(:performance,
                          title: 'Performance Four',
                          location: nil,
                          start_on: Date.new(2018, 12, 1)) }
    let!(:perf4_dup) { create(:performance,
                              title: 'Performance Four',
                              location: nil,
                              start_on: Date.new(2018, 12, 1)) }
    let!(:perf5) { create(:performance,
                          title: 'Performance Five',
                          location: nil,
                          start_on: Date.new(2019, 1, 1)) }
    let!(:perf6) { create(:performance,
                          title: 'Performance Six',
                          location: nil,
                          start_on: Date.new(2017, 12, 1)) }
    let!(:perf7) { create(:performance,
                          title: 'Performance Seven',
                          location: nil,
                          start_on: Date.new(2018, 1, 1)) }
    let!(:perf8) { create(:performance,
                          title: 'Performance Eight',
                          location: nil,
                          start_on: Date.new(2018, 1, 2)) }

    before do
      create(:user_performance,
             user: user,
             performance: perf1,
             visible_in_profile: true,
             position_in_profile: nil)
      create(:user_performance,
             user: user,
             performance: perf2,
             visible_in_profile: true,
             position_in_profile: nil)
      create(:user_performance,
             user: user,
             performance: perf3,
             visible_in_profile: true,
             position_in_profile: nil)
      create(:user_performance,
             user: user,
             performance: perf4,
             visible_in_profile: true,
             position_in_profile: nil)
      create(:user_performance,
             user: user,
             performance: perf4_dup,
             visible_in_profile: true,
             position_in_profile: nil)
      create(:user_performance,
             user: user,
             performance: perf5,
             visible_in_profile: true,
             position_in_profile: 2)
      create(:user_performance,
             user: user,
             performance: perf6,
             visible_in_profile: true,
             position_in_profile: 3)
      create(:user_performance,
             user: user,
             performance: perf7,
             visible_in_profile: true,
             position_in_profile: 1)
      create(:user_performance,
             user: user,
             performance: perf8,
             visible_in_profile: false,
             position_in_profile: 4)
    end

    it "returns an array of strings describing the given user's visible performances in order by date" do
      expect(profile.performances).to eq [
        'Performance Four, 12/1/2018',
        'Performance One, Location One, 1/1/2017',
        'Performance Two, 1/1/2016',
        'Performance Three, Location Three',
        'Performance Seven, 1/1/2018',
        'Performance Five, 1/1/2019',
        'Performance Six, 12/1/2017'
      ]
    end
  end

  describe '#performance_records' do
    let!(:other_user) { create(:user) }
    let!(:perf1) { create(:performance,
                          title: 'Performance One',
                          location: 'Location One',
                          start_on: Date.new(2017, 1, 1)) }
    let!(:perf2) { create(:performance,
                          title: 'Performance Two',
                          location: nil,
                          start_on: Date.new(2016, 1, 1)) }
    let!(:perf3) { create(:performance,
                          title: 'Performance Three',
                          location: 'Location Three',
                          start_on: nil) }
    let!(:perf4) { create(:performance,
                          title: 'Performance Four',
                          location: nil,
                          start_on: Date.new(2018, 12, 1)) }
    let!(:perf5) { create(:performance,
                          title: 'Performance Five',
                          location: nil,
                          start_on: Date.new(2019, 1, 1)) }
    let!(:perf6) { create(:performance,
                          title: 'Performance Six',
                          location: nil,
                          start_on: Date.new(2017, 12, 1)) }
    let!(:perf7) { create(:performance,
                          title: 'Performance Seven',
                          location: nil,
                          start_on: Date.new(2018, 1, 1)) }

    before do
      create(:user_performance,
             user: other_user,
             performance: perf1,
             visible_in_profile: true,
             position_in_profile: nil)
      create(:user_performance,
             user: user,
             performance: perf1,
             visible_in_profile: true,
             position_in_profile: nil)
      create(:user_performance,
             user: user,
             performance: perf2,
             visible_in_profile: false,
             position_in_profile: nil)
      create(:user_performance,
             user: user,
             performance: perf3,
             visible_in_profile: true,
             position_in_profile: nil)
      create(:user_performance,
             user: user,
             performance: perf4,
             visible_in_profile: true,
             position_in_profile: nil)
      create(:user_performance,
             user: user,
             performance: perf5,
             visible_in_profile: false,
             position_in_profile: 2)
      create(:user_performance,
             user: user,
             performance: perf6,
             visible_in_profile: true,
             position_in_profile: 3)
      create(:user_performance,
             user: user,
             performance: perf7,
             visible_in_profile: true,
             position_in_profile: 1)
    end

    it "returns an array of the given user's visible performances in order first by user preference, then by date" do
      expect(profile.performance_records).to eq [perf4, perf1, perf2, perf3, perf7, perf5, perf6]
    end
  end

  describe '#master_advising_roles' do
    let!(:m_etd1) { create(:etd,
                           title: 'Master ETD\n One',
                           url: 'test.edu/etd1',
                           submission_type: 'Master Thesis',
                           year: 2010,
                           author_first_name: 'First',
                           author_last_name: 'Author') }
    let!(:m_etd2) { create(:etd,
                           title: 'Master ETD\n Two',
                           url: 'test.edu/etd2',
                           submission_type: 'Master Thesis',
                           year: 2005,
                           author_first_name: 'Second',
                           author_last_name: 'Author') }
    let!(:m_etd3) { create(:etd,
                           title: 'Master ETD\n Three',
                           url: 'test.edu/etd3',
                           submission_type: 'Master Thesis',
                           year: 2015,
                           author_first_name: 'Third',
                           author_last_name: 'Author') }
    let!(:p_etd1) { create(:etd,
                           title: 'PhD ETD One',
                           url: 'test2.edu',
                           submission_type: 'Dissertation') }

    before do
      create(:committee_membership, user: user, etd: m_etd1, role: 'Committee Member')
      create(:committee_membership, user: user, etd: m_etd1, role: 'Outside Member')
      create(:committee_membership, user: user, etd: m_etd2, role: 'Committee Member')
      create(:committee_membership, user: user, etd: m_etd3, role: 'Committee Member')
      create(:committee_membership, user: user, etd: p_etd1, role: 'Committee Member')
    end

    it "returns an array of strings describing the given user's most significant advising role for each of their master thesis ETDs in order by year" do
      expect(profile.master_advising_roles).to eq [
        'Committee Member for Third Author - <a href="test.edu/etd3" target="_blank">Master ETD  Three</a> 2015',
        'Committee Member for First Author - <a href="test.edu/etd1" target="_blank">Master ETD  One</a> 2010',
        'Committee Member for Second Author - <a href="test.edu/etd2" target="_blank">Master ETD  Two</a> 2005'
      ]
    end
  end

  describe '#phd_advising_roles' do
    let!(:p_etd1) { create(:etd,
                           title: 'PhD ETD\n One',
                           url: 'test.edu/etd1',
                           submission_type: 'Dissertation',
                           year: 2010,
                           author_first_name: 'First',
                           author_last_name: 'Author') }
    let!(:p_etd2) { create(:etd,
                           title: 'PhD ETD\n Two',
                           url: 'test.edu/etd2',
                           submission_type: 'Dissertation',
                           year: 2005,
                           author_first_name: 'Second',
                           author_last_name: 'Author') }
    let!(:p_etd3) { create(:etd,
                           title: 'PhD ETD\n Three',
                           url: 'test.edu/etd3',
                           submission_type: 'Dissertation',
                           year: 2015,
                           author_first_name: 'Third',
                           author_last_name: 'Author') }
    let!(:m_etd1) { create(:etd,
                           title: 'Master ETD One',
                           url: 'test2.edu',
                           submission_type: 'Master Thesis') }

    before do
      create(:committee_membership, user: user, etd: p_etd1, role: 'Committee Member')
      create(:committee_membership, user: user, etd: p_etd1, role: 'Outside Member')
      create(:committee_membership, user: user, etd: p_etd2, role: 'Committee Member')
      create(:committee_membership, user: user, etd: p_etd3, role: 'Committee Member')
      create(:committee_membership, user: user, etd: m_etd1, role: 'Committee Member')
    end

    it "returns an array of strings describing the given user's most significant advising role for each of their PhD dissertation ETDs" do
      expect(profile.phd_advising_roles).to eq [
        'Committee Member for Third Author - <a href="test.edu/etd3" target="_blank">PhD ETD  Three</a> 2015',
        'Committee Member for First Author - <a href="test.edu/etd1" target="_blank">PhD ETD  One</a> 2010',
        'Committee Member for Second Author - <a href="test.edu/etd2" target="_blank">PhD ETD  Two</a> 2005'
      ]
    end
  end

  describe '#news_stories' do
    let!(:nfi1) { create(:news_feed_item,
                         user: user,
                         title: 'Story One',
                         url: 'news.edu/1',
                         published_on: Date.new(2016, 1, 2)) }
    let!(:nfi2) { create(:news_feed_item,
                         user: user,
                         title: 'Story Two',
                         url: 'news.edu/2',
                         published_on: Date.new(2018, 3, 4)) }

    it 'returns an array of strings describing news stories about the given user in order by date' do
      expect(profile.news_stories).to eq [
        '<a href="news.edu/2" target="_blank">Story Two</a> 3/4/2018',
        '<a href="news.edu/1" target="_blank">Story One</a> 1/2/2016'
      ]
    end
  end

  describe '#education_history' do
    context 'when the user has education history items' do
      let!(:item1) { create(:education_history_item,
                            user: user,
                            degree: 'MS',
                            emphasis_or_major: 'Ecology',
                            institution: 'The Pennsylvania State University',
                            end_year: 2003) }
      let!(:item2) { create(:education_history_item,
                            user: user,
                            degree: 'BS',
                            emphasis_or_major: 'Biology',
                            institution: 'University of Pittsburgh',
                            end_year: 2000) }
      let!(:item3) { create(:education_history_item,
                            user: user,
                            degree: nil,
                            emphasis_or_major: 'Biology',
                            institution: 'University of Pittsburgh',
                            end_year: 2000) }
      let!(:item4) { create(:education_history_item,
                            user: user,
                            degree: 'BS',
                            emphasis_or_major: nil,
                            institution: 'University of Pittsburgh',
                            end_year: 2000) }
      let!(:item5) { create(:education_history_item,
                            user: user,
                            degree: 'BS',
                            emphasis_or_major: 'Biology',
                            institution: nil,
                            end_year: 2000) }
      let!(:item6) { create(:education_history_item,
                            user: user,
                            degree: 'BS',
                            emphasis_or_major: 'Biology',
                            institution: 'University of Pittsburgh',
                            end_year: nil) }
      let!(:item7) { create(:education_history_item,
                            user: user,
                            degree: 'Other',
                            emphasis_or_major: 'Biology',
                            institution: 'University of Pittsburgh',
                            end_year: 2000) }

      it "returns an array of strings describing the user's education history in order by year" do
        expect(profile.education_history).to eq [
          'MS, Ecology - The Pennsylvania State University - 2003',
          'BS, Biology - University of Pittsburgh - 2000'
        ]
      end
    end

    context 'when the user has no education history items' do
      it 'returns an empty array' do
        expect(profile.education_history).to eq []
      end
    end
  end

  describe '#has_bio_info?' do
    let!(:user) { create(:user,
                         ai_bio: bio,
                         ai_teaching_interests: ti,
                         ai_research_interests: ri,
                         education_history_items: items) }
    let(:ehi) { build(:education_history_item,
                      degree: 'MS',
                      institution: 'Institution',
                      emphasis_or_major: 'Major',
                      end_year: 2000) }

    context 'when the user has a bio' do
      let(:bio) { 'A bio' }

      context 'when the user has research interests' do
        let(:ri) { 'Research Interests' }

        context 'when the user has teaching interests' do
          let(:ti) { 'Teaching Interests' }

          context 'when the user has education history' do
            let(:items) { [ehi] }

            it 'returns true' do
              expect(profile.has_bio_info?).to be true
            end
          end

          context 'when the user has no education history' do
            let(:items) { [] }

            it 'returns true' do
              expect(profile.has_bio_info?).to be true
            end
          end
        end

        context 'when the user has no teaching interests' do
          let(:ti) { nil }

          context 'when the user has education history' do
            let(:items) { [ehi] }

            it 'returns true' do
              expect(profile.has_bio_info?).to be true
            end
          end

          context 'when the user has no education history' do
            let(:items) { [] }

            it 'returns true' do
              expect(profile.has_bio_info?).to be true
            end
          end
        end
      end

      context 'when the user has no research interests' do
        let(:ri) { nil }

        context 'when the user has teaching interests' do
          let(:ti) { 'Teaching Interests' }

          context 'when the user has education history' do
            let(:items) { [ehi] }

            it 'returns true' do
              expect(profile.has_bio_info?).to be true
            end
          end

          context 'when the user has no education history' do
            let(:items) { [] }

            it 'returns true' do
              expect(profile.has_bio_info?).to be true
            end
          end
        end

        context 'when the user has no teaching interests' do
          let(:ti) { nil }

          context 'when the user has education history' do
            let(:items) { [ehi] }

            it 'returns true' do
              expect(profile.has_bio_info?).to be true
            end
          end

          context 'when the user has no education history' do
            let(:items) { [] }

            it 'returns true' do
              expect(profile.has_bio_info?).to be true
            end
          end
        end
      end
    end

    context 'when the user has no bio' do
      let(:bio) { nil }

      context 'when the user has research interests' do
        let(:ri) { 'Research Interests' }

        context 'when the user has teaching interests' do
          let(:ti) { 'Teaching Interests' }

          context 'when the user has education history' do
            let(:items) { [ehi] }

            it 'returns true' do
              expect(profile.has_bio_info?).to be true
            end
          end

          context 'when the user has no education history' do
            let(:items) { [] }

            it 'returns true' do
              expect(profile.has_bio_info?).to be true
            end
          end
        end

        context 'when the user has no teaching interests' do
          let(:ti) { nil }

          context 'when the user has education history' do
            let(:items) { [ehi] }

            it 'returns true' do
              expect(profile.has_bio_info?).to be true
            end
          end

          context 'when the user has no education history' do
            let(:items) { [] }

            it 'returns true' do
              expect(profile.has_bio_info?).to be true
            end
          end
        end
      end

      context 'when the user has no research interests' do
        let(:ri) { nil }

        context 'when the user has teaching interests' do
          let(:ti) { 'Teaching Interests' }

          context 'when the user has education history' do
            let(:items) { [ehi] }

            it 'returns true' do
              expect(profile.has_bio_info?).to be true
            end
          end

          context 'when the user has no education history' do
            let(:items) { [] }

            it 'returns true' do
              expect(profile.has_bio_info?).to be true
            end
          end
        end

        context 'when the user has no teaching interests' do
          let(:ti) { nil }

          context 'when the user has education history' do
            let(:items) { [ehi] }

            it 'returns true' do
              expect(profile.has_bio_info?).to be true
            end
          end

          context 'when the user has no education history' do
            let(:items) { [] }

            it 'returns false' do
              expect(profile.has_bio_info?).to be false
            end
          end
        end
      end
    end
  end
end
