# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin user detail page', type: :feature do
  let!(:user) { create(:user, :with_psu_identity,
                       first_name: 'Bob',
                       last_name: 'Testuser',
                       webaccess_id: 'bat123',
                       activity_insight_identifier: 'ai12345',
                       pure_uuid: 'pure67890',
                       penn_state_identifier: 'psu345678',
                       scopus_h_index: 724,
                       ai_title: 'Test Title',
                       orcid_identifier: 'Test Orcid ID',
                       ai_alt_name: 'Test Alt Name',
                       ai_building: 'Test Building',
                       ai_room_number: 'Test Room Number',
                       ai_office_area_code: 385,
                       ai_office_phone_1: 503,
                       ai_office_phone_2: 2953,
                       ai_fax_area_code: 743,
                       ai_fax_1: 298,
                       ai_fax_2: 1094,
                       ai_google_scholar: 'Test Google Scholar',
                       ai_website: 'http://test-example.com',
                       ai_bio: 'Test Bio',
                       ai_teaching_interests: 'Test Teaching Interests',
                       ai_research_interests: 'Test Research Interests') }

  let!(:pub1) { create(:publication, title: "Bob's First Publication",
                                     journal_title: 'First Journal',
                                     publisher_name: 'First Publisher',
                                     published_on: Date.new(2017, 1, 1)) }

  let!(:pub2) { create(:publication, title: "Bob's Second Publication",
                                     journal_title: 'Second Journal',
                                     publisher_name: 'Second Publisher',
                                     published_on: Date.new(2018, 1, 1),
                                     duplicate_group: group) }

  let!(:pres1) { create(:presentation, title: "Bob's First Presentation") }
  let!(:pres2) { create(:presentation, name: "Bob's Second Presentation") }

  let(:group) { create(:duplicate_publication_group) }

  let(:org1) { create(:organization, name: 'Test Org One') }
  let(:org2) { create(:organization, name: 'Test Org Two') }
  let!(:org3) { create(:organization, name: 'Managed Org', owner: user) }

  let(:con1) { create(:contract, title: 'Test Contract One') }
  let(:con2) { create(:contract, title: 'Test Contract Two') }

  let(:etd1) { create(:etd, title: 'Test ETD One') }
  let(:etd2) { create(:etd, title: 'Test ETD Two') }

  let!(:nfi1) { create(:news_feed_item, user: user, title:  'Test Story One') }
  let!(:nfi2) { create(:news_feed_item, user: user, title:  'Test Story Two') }

  let!(:perf1) { create(:performance, title: 'Test Performance One') }
  let!(:perf2) { create(:performance, title: 'Test Performance Two') }

  let!(:item1) { create(:education_history_item, user: user) }
  let!(:item2) { create(:education_history_item, user: user) }

  let!(:grant1) { create(:grant, wos_identifier: 'TestGrant123') }
  let!(:grant2) { create(:grant, wos_identifier: 'TestGrant456') }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      create(:authorship, user: user, publication: pub1)
      create(:authorship, user: user, publication: pub2)

      create(:presentation_contribution, user: user, presentation: pres1)
      create(:presentation_contribution, user: user, presentation: pres2)

      create(:user_organization_membership, user: user, organization: org1)
      create(:user_organization_membership, user: user, organization: org2)

      create(:user_contract, user: user, contract: con1)
      create(:user_contract, user: user, contract: con2)

      create(:committee_membership, user: user, etd: etd1)
      create(:committee_membership, user: user, etd: etd2)

      create(:user_performance, user: user, performance: perf1)
      create(:user_performance, user: user, performance: perf2)

      create(:researcher_fund, user: user, grant: grant1)
      create(:researcher_fund, user: user, grant: grant2)
    end

    describe 'the page content' do
      before { visit rails_admin.show_path(model_name: :user, id: user.id) }

      it 'shows the correct data for the user' do
        expect(page).to have_content "Details for User 'Bob Testuser'"
        expect(page).to have_content 'bat123'
        expect(page).to have_content(/{.*affiliation.*FACULTY.*}/)
        expect(page).to have_content 'ai12345'
        expect(page).to have_content 'pure67890'
        expect(page).to have_content 'psu345678'
        expect(page).to have_content '724'
        expect(page).to have_content 'Test Title'
        expect(page).to have_link 'Test Orcid ID', href: 'Test Orcid ID'
        expect(page).to have_content 'Test Alt Name'
        expect(page).to have_content 'Test Building'
        expect(page).to have_content 'Test Room Number'
        expect(page).to have_content '(385) 503-2953'
        expect(page).to have_content '(743) 298-1094'
        expect(page).to have_content 'http://test-example.com'
        expect(page).to have_content 'Test Google Scholar'
        expect(page).to have_content 'Test Bio'
        expect(page).to have_content 'Test Teaching Interests'
        expect(page).to have_content 'Test Research Interests'

        expect(page).to have_link "EducationHistoryItem ##{item1.id}"
        expect(page).to have_link "EducationHistoryItem ##{item2.id}"

        expect(page).to have_link 'Managed Org'

        expect(page).to have_link "Bob's First Publication"
        expect(page).to have_content 'First Journal'
        expect(page).to have_content 'First Publisher'
        expect(page).to have_content '2017'

        expect(page).to have_link "Bob's Second Publication"
        expect(page).to have_content 'Second Journal'
        expect(page).to have_content 'Second Publisher'
        expect(page).to have_content '2018'
        expect(page).to have_link "Duplicate group ##{group.id}"

        expect(page).to have_link "Bob's First Presentation"
        expect(page).to have_link "Bob's Second Presentation"

        expect(page).to have_link 'Bob Testuser - Test Org One'
        expect(page).to have_link 'Bob Testuser - Test Org Two'

        expect(page).to have_link 'Test Org One'
        expect(page).to have_link 'Test Org Two'

        expect(page).to have_link 'Test Contract One'
        expect(page).to have_link 'Test Contract Two'

        expect(page).to have_link 'TestGrant123'
        expect(page).to have_link 'TestGrant456'

        expect(page).to have_link 'Test ETD One'
        expect(page).to have_link 'Test ETD Two'

        expect(page).to have_link 'Test Story One'
        expect(page).to have_link 'Test Story Two'

        expect(page).to have_link 'Test Performance One'
        expect(page).to have_link 'Test Performance Two'
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.show_path(model_name: :user, id: user.id) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.show_path(model_name: :user, id: user.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
