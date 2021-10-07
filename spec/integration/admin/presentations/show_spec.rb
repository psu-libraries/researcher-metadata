require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin presentation detail page', type: :feature do
  let!(:pres) { create :presentation,
                       activity_insight_identifier: 'ai_abc123',
                       name: 'Test Name',
                       title: 'Test Title',
                       organization: 'Test Org',
                       location: 'Test Location',
                       started_on: Date.new(2018, 10, 10),
                       ended_on: Date.new(2018, 10, 11),
                       presentation_type: 'Test Type',
                       classification: 'Test Classification',
                       meet_type: 'Test Meet',
                       attendance: 345,
                       refereed: 'Yes',
                       abstract: 'Test Abstract',
                       comment: 'Test Comment',
                       scope: 'Test Scope' }

  let!(:user1) { create :user, first_name: 'Susan', last_name: 'Testuser' }
  let!(:user2) { create :user, first_name: 'Bob', last_name: 'Tester' }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      create :presentation_contribution, user: user1, presentation: pres
      create :presentation_contribution, user: user2, presentation: pres
    end

    describe 'the page content' do
      before { visit rails_admin.show_path(model_name: :presentation, id: pres.id) }

      it 'shows the presentation detail heading' do
        expect(page).to have_content "Details for Presentation 'Test Name - Test Title'"
      end

      it "shows the presentation's title" do
        expect(page).to have_content 'Test Title'
      end

      it "shows the presentation's Activity Insight identifier" do
        expect(page).to have_content 'ai_abc123'
      end

      it "shows the presentation's organization" do
        expect(page).to have_content 'Test Org'
      end

      it "shows the presentation's location" do
        expect(page).to have_content 'Test Location'
      end

      it "shows the presentation's start date" do
        expect(page).to have_content 'October 10, 2018'
      end

      it "shows the presentation's end date" do
        expect(page).to have_content 'October 11, 2018'
      end

      it "shows the presentation's type" do
        expect(page).to have_content 'Test Type'
      end

      it "shows the presentation's classification" do
        expect(page).to have_content 'Test Classification'
      end

      it "shows the presentation's meet type" do
        expect(page).to have_content 'Test Meet'
      end

      it "shows the presentation's attendance" do
        expect(page).to have_content '345'
      end

      it "shows the presentation's refereed value" do
        expect(page).to have_content 'Yes'
      end

      it "shows the presentation's abstract" do
        expect(page).to have_content 'Test Abstract'
      end

      it "shows the presentation's comment" do
        expect(page).to have_content 'Test Comment'
      end

      it "shows the presentation's scope" do
        expect(page).to have_content 'Test Scope'
      end

      it "shows the presentation's users" do
        expect(page).to have_link 'Susan Testuser'
        expect(page).to have_link 'Bob Tester'
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.show_path(model_name: :presentation, id: pres.id) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.show_path(model_name: :presentation, id: pres.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
