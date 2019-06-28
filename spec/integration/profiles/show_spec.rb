require 'integration/integration_spec_helper'

feature "Profile page", type: :feature do
  let!(:user) { create :user,
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
                       show_all_contracts: true }
  let!(:pub1) { create :publication,
                       total_scopus_citations: 5,
                       visible: true,
                       title: 'First Publication',
                       journal_title: 'Journal 1',
                       published_on: Date.new(2010, 1, 1) }
  let!(:pub2) { create :publication,
                       total_scopus_citations: 17,
                       visible: true,
                       title: 'Second Publication',
                       journal_title: 'Journal 2',
                       published_on: Date.new(2011, 1, 1) }
  let!(:con1) { create :contract,
                       title: 'First Grant',
                       sponsor: 'Sponsor 1',
                       award_start_on: Time.new(2015, 1, 1, 0, 0, 0),
                       award_end_on: Time.new(2015, 6, 1, 0, 0, 0),
                       visible: true }
  let!(:con2) { create :contract,
                       title: 'Second Grant',
                       sponsor: 'Sponsor 2',
                       award_start_on: Time.new(2016, 1, 1, 0, 0, 0),
                       award_end_on: Time.new(2016, 6, 1, 0, 0, 0),
                       visible: true }
  let!(:pres1) { create :presentation,
                        visible: true,
                        title: 'First Presentation',
                        organization: 'Organization 1',
                        location: 'Location 1' }
  let!(:pres2) { create :presentation,
                        visible: true,
                        title: 'Second Presentation',
                        organization: 'Organization 2',
                        location: 'Location 2' }
  let!(:perf1) { create :performance,
                        visible: true,
                        title: 'First Performance',
                        location: 'Location 1',
                        start_on: Date.new(2018, 1, 2) }
  let!(:perf2) { create :performance,
                        visible: true,
                        title: 'Second Performance',
                        location: 'Location 2',
                        start_on: Date.new(2019, 1, 2) }
  let!(:etd1) { create :etd,
                       title: 'First Thesis',
                       author_first_name: 'Anne',
                       author_last_name: 'Author',
                       year: 1998, submission_type: 'Master Thesis' }
  let!(:etd2) { create :etd,
                       title: 'Second Thesis',
                       author_first_name: 'Another',
                       author_last_name: 'Author',
                       year: 1999, submission_type: 'Dissertation' }

  before do
    create :authorship, user: user, publication: pub1
    create :authorship, user: user, publication: pub2

    create :user_contract, user: user, contract: con1
    create :user_contract, user: user, contract: con2

    create :presentation_contribution, user: user, presentation: pres1
    create :presentation_contribution, user: user, presentation: pres2

    create :user_performance, user: user, performance: perf1
    create :user_performance, user: user, performance: perf2

    create :education_history_item,
           user: user,
           degree: 'MS',
           institution: 'Institution 1',
           emphasis_or_major: 'Major 1',
           end_year: 2000
    create :education_history_item,
           user: user,
           degree: 'PhD',
           institution: 'Institution 2',
           emphasis_or_major: 'Major 2',
           end_year: 2005

    create :committee_membership, user: user, etd: etd1, role: 'Committee Member'
    create :committee_membership, user: user, etd: etd2, role: 'Committee Chair'

    create :news_feed_item,
           user: user,
           title: 'First Story',
           published_on: Date.new(2016, 1, 2)
    create :news_feed_item,
           user: user,
           title: 'Second Story',
           published_on: Date.new(2017, 3, 4)

    visit profile_path(webaccess_id: 'abc123')
  end

  it "shows the profile layout" do
    expect(page).to have_link "Privacy and Legal Statements"
  end

  it "shows the name of the requested user" do
    expect(page).to have_content 'Bob Testuser'
  end

  it "shows the office location for the requested user" do
    expect(page).to have_content '123 Office Building'
  end

  it "shows the email address for the requested user" do
    expect(page).to have_link 'abc123@psu.edu', href: 'mailto:abc123@psu.edu'
  end

  it "shows the H-index for the requested user" do
    expect(page).to have_content 'Scopus H-index'
    expect(page).to have_content '18'
  end

  it "shows the requested user's number of citations" do
    expect(page).to have_content 'Scopus Citations'
    expect(page).to have_content '22'
  end

  it "shows a link to the requested user's Pure profile" do
    expect(page).to have_link 'Pure Profile', href: 'https://pennstate.pure.elsevier.com/en/persons/xyz789'
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
    end
  end

  it "shows the requested user's grants in the Grants tab" do
    within '#grants' do
      expect(page).to have_content 'Grants'
      expect(page).to have_content 'First Grant, Sponsor 1, 1/2015 - 6/2015'
      expect(page).to have_content 'Second Grant, Sponsor 2, 1/2016 - 6/2016'
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
end
