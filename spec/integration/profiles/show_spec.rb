# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'Profile page', type: :feature do
  let!(:user) { create(:user,
                       :with_psu_identity,
                       webaccess_id: 'abc123',
                       first_name: 'Bob',
                       last_name: 'Testuser',
                       ai_room_number: '123',
                       ai_building: 'Office Building',
                       scopus_h_index: '18',
                       pure_uuid: 'xyz789',
                       ai_research_interests: 'My interests for research',
                       ai_teaching_interests: 'My interests for teaching',
                       ai_bio: 'My bio information',
                       show_all_publications: true,
                       show_all_contracts: true,
                       ai_office_area_code: '123',
                       ai_office_phone_1: '456',
                       ai_office_phone_2: '7890')}
  let!(:pub1) { create(:publication,
                       total_scopus_citations: 5,
                       visible: true,
                       title: 'First Publication',
                       journal_title: 'Journal 1',
                       published_on: Date.new(2010, 1, 1)) }
  let!(:pub2) { create(:publication,
                       total_scopus_citations: 17,
                       visible: true,
                       title: 'Second Publication',
                       journal_title: 'Journal 2',
                       published_on: Date.new(2011, 1, 1),
                       open_access_locations: [build(:open_access_location,
                                                     source: Source::OPEN_ACCESS_BUTTON,
                                                     url: 'https://example.org/pubs/123.pdf')]) }
  let!(:pub3) { create(:publication,
                       publication_type: 'Book',
                       visible: true,
                       title: 'Third Publication',
                       journal_title: 'Journal 3',
                       published_on: Date.new(2013, 1, 1)) }
  let!(:pub4) { create(:publication,
                       publication_type: 'Conference Proceeding',
                       visible: true,
                       title: 'Fourth Publication',
                       journal_title: 'Journal 4',
                       published_on: Date.new(2010, 1, 1)) }
  let!(:pres1) { create(:presentation,
                        visible: true,
                        title: 'First Presentation',
                        organization: 'Organization 1',
                        location: 'Location 1') }
  let!(:pres2) { create(:presentation,
                        visible: true,
                        title: 'Second Presentation',
                        organization: 'Organization 2',
                        location: 'Location 2') }
  let!(:perf1) { create(:performance,
                        visible: true,
                        title: 'First Performance',
                        location: 'Location 1',
                        start_on: Date.new(2018, 1, 2)) }
  let!(:perf2) { create(:performance,
                        visible: true,
                        title: 'Second Performance',
                        location: 'Location 2',
                        start_on: Date.new(2019, 1, 2)) }
  let!(:etd1) { create(:etd,
                       title: 'First Thesis',
                       author_first_name: 'Anne',
                       author_last_name: 'Author',
                       year: 1998, submission_type: 'Master Thesis') }
  let!(:etd2) { create(:etd,
                       title: 'Second Thesis',
                       author_first_name: 'Another',
                       author_last_name: 'Author',
                       year: 1999, submission_type: 'Dissertation') }
  let!(:org) { create(:organization, name: 'Test Organization') }
  let!(:grant1) { create(:grant,
                         title: 'First Grant',
                         agency_name: 'National Science Foundation',
                         start_date: Date.new(2001, 2, 3),
                         end_date: Date.new(2004, 5, 6)) }
  let!(:grant2) { create(:grant,
                         identifier: 'Grant123',
                         wos_agency_name: 'Agency 2',
                         start_date: Date.new(2010, 1, 1),
                         end_date: Date.new(2015, 2, 2)) }

  before do
    create(:authorship, user: user, publication: pub1)
    create(:authorship, user: user, publication: pub2)
    create(:authorship, user: user, publication: pub3)
    create(:authorship, user: user, publication: pub4)

    create(:presentation_contribution, user: user, presentation: pres1)
    create(:presentation_contribution, user: user, presentation: pres2)

    create(:user_performance, user: user, performance: perf1)
    create(:user_performance, user: user, performance: perf2)

    create(:education_history_item,
           user: user,
           degree: 'MS',
           institution: 'Institution 1',
           emphasis_or_major: 'Major 1',
           end_year: 2000)
    create(:education_history_item,
           user: user,
           degree: 'PhD',
           institution: 'Institution 2',
           emphasis_or_major: 'Major 2',
           end_year: 2005)

    create(:committee_membership, user: user, etd: etd1, role: 'Committee Member')
    create(:committee_membership, user: user, etd: etd2, role: 'Committee Chair')

    create(:news_feed_item,
           user: user,
           title: 'First Story',
           published_on: Date.new(2016, 1, 2))
    create(:news_feed_item,
           user: user,
           title: 'Second Story',
           published_on: Date.new(2017, 3, 4))

    create(:user_organization_membership,
           user: user,
           organization: org,
           import_source: 'Pure',
           source_identifier: 'pure123')

    create(:researcher_fund, grant: grant1, user: user)
    create(:researcher_fund, grant: grant2, user: user)
  end

  context 'when the profile is active' do
    before { visit profile_path(webaccess_id: 'abc123') }

    it 'shows the profile layout' do
      expect(page).to have_link '2019 The Pennsylvania State University'
    end

    it 'shows the name of the requested user' do
      expect(page).to have_content 'Bob Testuser'
    end

    it "shows the name of the requested user's organization" do
      expect(page).to have_content 'Test Organization'
    end

    it 'shows the office location for the requested user' do
      expect(page).to have_content '123 Office Building'
    end

    it 'shows the office phone number for the requested user' do
      expect(page).to have_content '(123) 456-7890'
    end

    it 'shows the email address for the requested user' do
      expect(page).to have_link 'abc123@psu.edu', href: 'mailto:abc123@psu.edu'
    end

    it 'shows the H-index for the requested user' do
      expect(page).to have_content 'Scopus H-index'
      expect(page).to have_content '18'
    end

    it "shows the requested user's number of citations" do
      expect(page).to have_content 'Scopus Citations'
      expect(page).to have_content '22'
    end

    it "shows a link to the requested user's Pure profile" do
      expect(page).to have_link 'Pure Profile', href: 'https://pure.psu.edu/en/persons/xyz789'
    end

    it "shows the requested user's research interests in the sidebar" do
      within '.research' do
        expect(page).to have_content 'Research Interests'
        expect(page).to have_content 'My interests for research'
      end
    end

    it "shows the requested user's bio information in the Bio tab" do
      within '#bio' do
        expect(page).to have_content 'Biography'
        expect(page).to have_content 'My bio information'
      end
    end

    it "shows the requested user's research interests in the Bio tab" do
      within '#bio' do
        expect(page).to have_content 'Research Interests'
        expect(page).to have_content 'My interests for research'
      end
    end

    it "shows the requested user's teaching interests in the Bio tab" do
      within '#bio' do
        expect(page).to have_content 'Teaching Interests'
        expect(page).to have_content 'My interests for teaching'
      end
    end

    it "shows the requested user's education history in the Bio tab" do
      within '#bio' do
        expect(page).to have_content 'Education'
        expect(page).to have_content 'PhD, Major 2 - Institution 2 - 2005'
        expect(page).to have_content 'MS, Major 1 - Institution 1 - 2000'
      end
    end

    it "shows the requested user's publications in the Publications tab" do
      within '#publications' do
        expect(page).to have_content 'Publications'
        expect(page).to have_content 'First Publication, Journal 1, 2010'
        expect(page).to have_content 'Second Publication, Journal 2, 2011'
        expect(page).to have_link 'Second Publication', href: 'https://example.org/pubs/123.pdf'
        expect(page).to have_content 'Fourth Publication, Journal 4, 2010'
      end
    end

    it "shows the requested user's presentations in the Presentations tab" do
      within '#presentations' do
        expect(page).to have_content 'Presentations'
        expect(page).to have_content 'First Presentation, Organization 1, Location 1'
        expect(page).to have_content 'Second Presentation, Organization 2, Location 2'
      end
    end

    it "shows the requested user's performances in the Performances tab" do
      within '#performances' do
        expect(page).to have_content 'Performances'
        expect(page).to have_content 'First Performance, Location 1, 1/2/2018'
        expect(page).to have_content 'Second Performance, Location 2, 1/2/2019'
      end
    end

    it "shows the requested user's PhD advising roles in the Graduate Advising tab" do
      within '#advising' do
        expect(page).to have_content 'Graduate Advising'
        expect(page).to have_content 'PhD Committees'
        expect(page).to have_content 'Committee Chair for Another Author'
        expect(page).to have_link 'Second Thesis'
        expect(page).to have_content '1999'
      end
    end

    it "shows the requested user's masters advising roles in the Graduate Advising tab" do
      within '#advising' do
        expect(page).to have_content 'Masters Committees'
        expect(page).to have_content 'Committee Member for Anne Author'
        expect(page).to have_link 'First Thesis'
        expect(page).to have_content '1998'
      end
    end

    it "shows the requested user's new stories in the News tab" do
      within '#news' do
        expect(page).to have_content 'News'
        expect(page).to have_link 'First Story'
        expect(page).to have_content '1/2/2016'
        expect(page).to have_link 'Second Story'
        expect(page).to have_content '3/4/2017'
      end
    end

    it "shows the requested user's grants in the Grants tab" do
      within '#grants' do
        expect(page).to have_content 'Grants'
        expect(page).to have_content 'First Grant, National Science Foundation, 2/2001 - 5/2004'
        expect(page).to have_content 'Grant123, Agency 2, 1/2010 - 2/2015'
      end
    end

    it "shows the requested user's other publications in the Others tab" do
      within '#other-publications' do
        expect(page).to have_content 'Books'
        expect(page).not_to have_content 'Letters'
        expect(page).to have_content 'Third Publication, Journal 3, 2013'
        expect(page).not_to have_content 'Conference Proceedings'
        expect(page).not_to have_content 'Fourth Publication, Journal 4, 2010'
      end
    end
  end

  context 'when the profile is inactive' do
    before do
      user.update(psu_identity: nil)
      visit profile_path(webaccess_id: 'abc123')
    end

    it 'does NOT show the email' do
      expect(page).not_to have_link 'abc123@psu.edu', href: 'mailto:abc123@psu.edu'
    end
  end
end
