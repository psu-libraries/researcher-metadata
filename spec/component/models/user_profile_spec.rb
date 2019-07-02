require 'component/component_spec_helper'

describe UserProfile do
  let!(:user) { create :user,
                       webaccess_id: 'abc123',
                       ai_title: 'test title',
                       ai_website: 'www.test.com',
                       ai_bio: 'test bio',
                       show_all_publications: true,
                       show_all_contracts: true,
                       ai_teaching_interests: 'test teaching interests',
                       ai_research_interests: 'test research interests' }

  subject(:profile) { UserProfile.new(user) }

  it { is_expected.to delegate_method(:id).to(:user) }
  it { is_expected.to delegate_method(:name).to(:user) }
  it { is_expected.to delegate_method(:office_location).to(:user) }
  it { is_expected.to delegate_method(:total_scopus_citations).to(:user) }
  it { is_expected.to delegate_method(:scopus_h_index).to(:user) }
  it { is_expected.to delegate_method(:pure_profile_url).to(:user) }

  describe '#title' do
    it "returns the given user's title from Activity Insight" do
      expect(profile.title).to eq 'test title'
    end
  end
  describe '#email' do
    it "returns the email address for the given user based on their webaccess ID" do
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
    let!(:other_user) { create :user }
    let!(:pub1) { create :publication, title: "First Publication",
                         visible: true,
                         journal_title: "Test Journal",
                         published_on: Date.new(2010, 1, 1),
                         total_scopus_citations: 4 }
    let!(:pub2) { create :publication, title: "Second Publication",
                         visible: true,
                         publisher: "Test Publisher",
                         published_on: Date.new(2015, 1, 1) }
    let!(:pub3) { create :publication, title: "Third Publication",
                         visible: true,
                         published_on: Date.new(2018, 1, 1),
                         total_scopus_citations: 5 }
    let!(:pub4) { create :publication, title: "Undated Publication",
                         visible: true }
    let!(:pub5) { create :publication,
                         title: "Invisible Publication",
                         visible: false }
    let!(:pub6) { create :publication, title: "Hidden Authorship Publication",
                         visible: true }
    let(:pos1) { nil }
    let(:pos2) { nil }
    let(:pos3) { nil }
    let(:pos4) { nil }
    let(:pos5) { nil }
    let(:pos6) { nil }

    before do
      create :authorship, user: user, publication: pub1, position_in_profile: pos1
      create :authorship, user: user, publication: pub2, position_in_profile: pos2
      create :authorship, user: user, publication: pub3, position_in_profile: pos3
      create :authorship, user: user, publication: pub4, position_in_profile: pos4
      create :authorship, user: user, publication: pub5, position_in_profile: pos5
      create :authorship, user: user, publication: pub6, position_in_profile: pos6, visible_in_profile: false

      create :authorship, user: other_user, publication: pub1
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
    let!(:pub1) { create :publication,
                         title: "First Publication",
                         visible: true,
                         published_on: Date.new(2010, 1, 1) }
    let!(:pub2) { create :publication,
                         title: "Second Publication",
                         visible: true,
                         published_on: Date.new(2015, 1, 1) }
    let!(:pub3) { create :publication,
                         title: "Third Publication",
                         visible: true,
                         published_on: Date.new(2018, 1, 1) }
    let!(:pub4) { create :publication,
                         title: "Undated Publication",
                         visible: true }
    let!(:pub5) { create :publication,
                         title: "Invisible Publication",
                         visible: false }
    let(:pos1) { nil }
    let(:pos2) { nil }
    let(:pos3) { nil }
    let(:pos4) { nil }
    let(:pos5) { nil }

    before do
      create :authorship, user: user, publication: pub1, position_in_profile: pos1
      create :authorship, user: user, publication: pub2, position_in_profile: pos2
      create :authorship, user: user, publication: pub3, position_in_profile: pos3
      create :authorship, user: user, publication: pub4, position_in_profile: pos4
      create :authorship, user: user, publication: pub5, position_in_profile: pos5
    end

    context "when none of the user's authorships have a profile position" do
      it "returns an array of strings describing the given user's publications in order by date" do
        expect(profile.publication_records).to eq [pub4, pub3, pub2, pub1]
      end
    end
    context "when one of the user's authorships has a profile position set" do
      let(:pos2) { 1 }

      it "returns an array of strings describing the given user's publications in order first by position, then by date" do
        expect(profile.publication_records).to eq [pub4, pub3, pub1, pub2]
      end
    end
    context "when all of the user's authorships have profile positions set" do
      let(:pos1) { 5 }
      let(:pos2) { 3 }
      let(:pos3) { 2 }
      let(:pos4) { 6 }
      let(:pos5) { 4 }

      it "returns an array of strings describing the given user's publications in order by position" do
        expect(profile.publication_records).to eq [pub3, pub2, pub1, pub4]
      end
    end
  end

  describe '#grants' do
    let!(:con1) { create :contract,
                         contract_type: "Contract",
                         status: "Awarded",
                         title: "Awarded Contract",
                         visible: true }
    let!(:con2) { create :contract,
                         contract_type: "Grant",
                         status: "Pending",
                         title: "Pending Grant",
                         visible: true }
    let!(:con3) { create :contract,
                         contract_type: "Grant",
                         status: "Awarded",
                         title: "Awarded Grant One",
                         sponsor: "Test Sponsor",
                         award_start_on: Date.new(2010, 1, 1),
                         award_end_on: Date.new(2010, 5, 1),
                         visible: true }
    let!(:con4) { create :contract,
                         contract_type: "Grant",
                         status: "Awarded",
                         title: "Awarded Grant Two",
                         sponsor: "Other Sponsor",
                         award_start_on: Date.new(2015, 2, 1),
                         award_end_on: Date.new(2016, 1, 1),
                         visible: true }
    let!(:con5) { create :contract,
                         contract_type: "Grant",
                         status: "Awarded",
                         title: "Awarded Grant Three",
                         sponsor: "Sponsor",
                         award_start_on: nil,
                         visible: true }
    let!(:con6) { create :contract,
                         contract_type: "Grant",
                         status: "Awarded",
                         title: "Invisible Awarded Grant",
                         visible: false }
    let!(:con7) { create :contract,
                         contract_type: "Grant",
                         status: "Awarded",
                         title: "Hidden by other",
                         visible: true }
    let(:other_user) { create :user, show_all_contracts: false }

    before do
      create :user_contract, user: user, contract: con1
      create :user_contract, user: user, contract: con2
      create :user_contract, user: user, contract: con3
      create :user_contract, user: user, contract: con4
      create :user_contract, user: user, contract: con5
      create :user_contract, user: user, contract: con6
      create :user_contract, user: user, contract: con7
      create :user_contract, user: other_user, contract: con7
    end
    it "returns an array of strings describing the given user's visible, awarded grants in order by date" do
      expect(profile.grants).to eq [
                                     "Awarded Grant Three, Sponsor",
                                     "Awarded Grant Two, Other Sponsor, 2/2015 - 1/2016",
                                     "Awarded Grant One, Test Sponsor, 1/2010 - 5/2010"
                                   ]
    end
  end

  describe '#presentations' do
    let!(:pres1) { create :presentation,
                          name: "Presentation Two",
                          organization: "An Organization",
                          location: "Earth",
                          visible: true }
    let!(:pres2) { create :presentation,
                          title: nil,
                          name: nil,
                          visible: true }
    let!(:pres3) { create :presentation,
                          name: "Presentation Three",
                          organization: "Org",
                          location: "Here",
                          visible: false }

    before do
      create :presentation_contribution, user: user, presentation: pres1
      create :presentation_contribution, user: user, presentation: pres2
      create :presentation_contribution, user: user, presentation: pres3
    end

    it "returns an array of strings describing the given user's visible presentations" do
      expect(profile.presentations).to eq ["Presentation Two, An Organization, Earth"]
    end
  end

  describe '#performances' do
    let!(:perf1) { create :performance,
                          title: "Performance One",
                          location: "Location One",
                          start_on: Date.new(2017, 1, 1) }
    let!(:perf2) { create :performance,
                          title: "Performance Two",
                          location: nil,
                          start_on: nil }
    let!(:perf3) { create :performance,
                          title: "Performance Three",
                          location: "Location Three",
                          start_on: nil }
    let!(:perf4) { create :performance,
                          title: "Performance Four",
                          location: nil,
                          start_on: Date.new(2018, 12, 1) }
    let!(:perf4_dup) { create :performance,
                              title: "Performance Four",
                              location: nil,
                              start_on: Date.new(2018, 12, 1) }
    
    before do
      create :user_performance, user: user, performance: perf1
      create :user_performance, user: user, performance: perf2
      create :user_performance, user: user, performance: perf3
      create :user_performance, user: user, performance: perf4
      create :user_performance, user: user, performance: perf4_dup
    end

    it "returns an array of strings describing the given user's visible performances in order by date" do
      expect(profile.performances).to eq [
                                            "Performance Four, 12/1/2018",
                                            "Performance One, Location One, 1/1/2017",
                                            "Performance Two",
                                            "Performance Three, Location Three"
                                         ]
    end
  end

  describe '#master_advising_roles' do
    let!(:m_etd1) { create :etd,
                           title: 'Master ETD\n One',
                           url: "test.edu/etd1",
                           submission_type: 'Master Thesis',
                           year: 2010,
                           author_first_name: 'First',
                           author_last_name: 'Author' }
    let!(:m_etd2) { create :etd,
                           title: 'Master ETD\n Two',
                           url: "test.edu/etd2",
                           submission_type: 'Master Thesis',
                           year: 2005,
                           author_first_name: 'Second',
                           author_last_name: 'Author' }
    let!(:m_etd3) { create :etd,
                           title: 'Master ETD\n Three',
                           url: "test.edu/etd3",
                           submission_type: 'Master Thesis',
                           year: 2015,
                           author_first_name: 'Third',
                           author_last_name: 'Author' }
    let!(:p_etd1) { create :etd,
                           title: 'PhD ETD One',
                           url: "test2.edu",
                           submission_type: 'Dissertation' }

    before do
      create :committee_membership, user: user, etd: m_etd1, role: "Committee Member"
      create :committee_membership, user: user, etd: m_etd1, role: "Outside Member"
      create :committee_membership, user: user, etd: m_etd2, role: "Committee Member"
      create :committee_membership, user: user, etd: m_etd3, role: "Committee Member"
      create :committee_membership, user: user, etd: p_etd1, role: "Committee Member"
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
    let!(:p_etd1) { create :etd,
                           title: 'PhD ETD\n One',
                           url: "test.edu/etd1",
                           submission_type: 'Dissertation',
                           year: 2010,
                           author_first_name: 'First',
                           author_last_name: 'Author' }
    let!(:p_etd2) { create :etd,
                           title: 'PhD ETD\n Two',
                           url: "test.edu/etd2",
                           submission_type: 'Dissertation',
                           year: 2005,
                           author_first_name: 'Second',
                           author_last_name: 'Author' }
    let!(:p_etd3) { create :etd,
                           title: 'PhD ETD\n Three',
                           url: "test.edu/etd3",
                           submission_type: 'Dissertation',
                           year: 2015,
                           author_first_name: 'Third',
                           author_last_name: 'Author' }
    let!(:m_etd1) { create :etd,
                           title: 'Master ETD One',
                           url: "test2.edu",
                           submission_type: 'Master Thesis' }

    before do
      create :committee_membership, user: user, etd: p_etd1, role: "Committee Member"
      create :committee_membership, user: user, etd: p_etd1, role: "Outside Member"
      create :committee_membership, user: user, etd: p_etd2, role: "Committee Member"
      create :committee_membership, user: user, etd: p_etd3, role: "Committee Member"
      create :committee_membership, user: user, etd: m_etd1, role: "Committee Member"
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
    let!(:nfi1) { create :news_feed_item,
                         user: user,
                         title: "Story One",
                         url: "news.edu/1",
                         published_on: Date.new(2016, 1, 2) }
    let!(:nfi2) { create :news_feed_item,
                         user: user,
                         title: "Story Two",
                         url: "news.edu/2",
                         published_on: Date.new(2018, 3, 4) }

    it "returns an array of strings describing news stories about the given user in order by date" do
      expect(profile.news_stories).to eq [
                                            '<a href="news.edu/2" target="_blank">Story Two</a> 3/4/2018',
                                            '<a href="news.edu/1" target="_blank">Story One</a> 1/2/2016'
                                         ]
    end
  end

  describe '#education_history' do
    context "when the user has education history items" do
      let!(:item1) { create :education_history_item,
                            user: user,
                            degree: 'MS',
                            emphasis_or_major: 'Ecology',
                            institution: 'The Pennsylvania State University',
                            end_year: 2003 }
      let!(:item2) { create :education_history_item,
                            user: user,
                            degree: 'BS',
                            emphasis_or_major: 'Biology',
                            institution: 'University of Pittsburgh',
                            end_year: 2000 }
      let!(:item3) { create :education_history_item,
                            user: user,
                            degree: nil,
                            emphasis_or_major: 'Biology',
                            institution: 'University of Pittsburgh',
                            end_year: 2000 }
      let!(:item4) { create :education_history_item,
                            user: user,
                            degree: 'BS',
                            emphasis_or_major: nil,
                            institution: 'University of Pittsburgh',
                            end_year: 2000 }
      let!(:item5) { create :education_history_item,
                            user: user,
                            degree: 'BS',
                            emphasis_or_major: 'Biology',
                            institution: nil,
                            end_year: 2000 }
      let!(:item6) { create :education_history_item,
                            user: user,
                            degree: 'BS',
                            emphasis_or_major: 'Biology',
                            institution: 'University of Pittsburgh',
                            end_year: nil }
      let!(:item7) { create :education_history_item,
                            user: user,
                            degree: 'Other',
                            emphasis_or_major: 'Biology',
                            institution: 'University of Pittsburgh',
                            end_year: 2000 }

      it "returns an array of strings describing the user's education history in order by year" do
        expect(profile.education_history).to eq [
                                                  'MS, Ecology - The Pennsylvania State University - 2003',
                                                  'BS, Biology - University of Pittsburgh - 2000'
                                                ]
      end
    end
    context "when the user has no education history items" do
      it "returns an empty array" do
        expect(profile.education_history).to eq []
      end
    end
  end

  describe '#has_bio_info?' do
    let!(:user) { create :user,
                         ai_bio: bio,
                         ai_teaching_interests: ti,
                         ai_research_interests: ri,
                         education_history_items: items }
    let(:ehi) { build :education_history_item,
                      degree: 'MS',
                      institution: 'Institution',
                      emphasis_or_major: 'Major',
                      end_year: 2000 }

    context "when the user has a bio" do
      let(:bio) { "A bio" }
      context "when the user has research interests" do
        let(:ri) { "Research Interests" }
        context "when the user has teaching interests" do
          let(:ti) { "Teaching Interests" }
          context "when the user has education history" do
            let(:items) { [ehi] }

            it "returns true" do
              expect(profile.has_bio_info?).to eq true
            end
          end
          context "when the user has no education history" do
            let(:items) { [] }

            it "returns true" do
              expect(profile.has_bio_info?).to eq true
            end
          end
        end
        context "when the user has no teaching interests" do
          let(:ti) { nil }
          context "when the user has education history" do
            let(:items) { [ehi] }

            it "returns true" do
              expect(profile.has_bio_info?).to eq true
            end
          end
          context "when the user has no education history" do
            let(:items) { [] }

            it "returns true" do
              expect(profile.has_bio_info?).to eq true
            end
          end
        end
      end
      context "when the user has no research interests" do
        let(:ri) { nil }
        context "when the user has teaching interests" do
          let(:ti) { "Teaching Interests" }
          context "when the user has education history" do
            let(:items) { [ehi] }

            it "returns true" do
              expect(profile.has_bio_info?).to eq true
            end
          end
          context "when the user has no education history" do
            let(:items) { [] }

            it "returns true" do
              expect(profile.has_bio_info?).to eq true
            end
          end
        end
        context "when the user has no teaching interests" do
          let(:ti) { nil }
          context "when the user has education history" do
            let(:items) { [ehi] }

            it "returns true" do
              expect(profile.has_bio_info?).to eq true
            end
          end
          context "when the user has no education history" do
            let(:items) { [] }

            it "returns true" do
              expect(profile.has_bio_info?).to eq true
            end
          end
        end
      end
    end
    context "when the user has no bio" do
      let(:bio) { nil }
      context "when the user has research interests" do
        let(:ri) { "Research Interests" }
        context "when the user has teaching interests" do
          let(:ti) { "Teaching Interests" }
          context "when the user has education history" do
            let(:items) { [ehi] }

            it "returns true" do
              expect(profile.has_bio_info?).to eq true
            end
          end
          context "when the user has no education history" do
            let(:items) { [] }

            it "returns true" do
              expect(profile.has_bio_info?).to eq true
            end
          end
        end
        context "when the user has no teaching interests" do
          let(:ti) { nil }
          context "when the user has education history" do
            let(:items) { [ehi] }

            it "returns true" do
              expect(profile.has_bio_info?).to eq true
            end
          end
          context "when the user has no education history" do
            let(:items) { [] }

            it "returns true" do
              expect(profile.has_bio_info?).to eq true
            end
          end
        end
      end
      context "when the user has no research interests" do
        let(:ri) { nil }
        context "when the user has teaching interests" do
          let(:ti) { "Teaching Interests" }
          context "when the user has education history" do
            let(:items) { [ehi] }

            it "returns true" do
              expect(profile.has_bio_info?).to eq true
            end
          end
          context "when the user has no education history" do
            let(:items) { [] }

            it "returns true" do
              expect(profile.has_bio_info?).to eq true
            end
          end
        end
        context "when the user has no teaching interests" do
          let(:ti) { nil }
          context "when the user has education history" do
            let(:items) { [ehi] }

            it "returns true" do
              expect(profile.has_bio_info?).to eq true
            end
          end
          context "when the user has no education history" do
            let(:items) { [] }

            it "returns false" do
              expect(profile.has_bio_info?).to eq false
            end
          end
        end
      end
    end
  end
end
