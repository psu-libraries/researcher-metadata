# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin education history item detail page', type: :feature do
  let!(:item) { create(:education_history_item,
                       user: user,
                       activity_insight_identifier: '1234567890',
                       degree: 'Test Degree',
                       explanation_of_other_degree: 'Test explanation',
                       is_honorary_degree: 'Yes honorary',
                       is_highest_degree_earned: 'Not highest',
                       institution: 'Test Institution',
                       school: 'Test School',
                       location_of_institution: 'Test Location',
                       emphasis_or_major: 'Test Major',
                       supporting_areas_of_emphasis: 'Test areas',
                       dissertation_or_thesis_title: 'Test Title',
                       honor_or_distinction: 'Test Honor',
                       description: 'Test description',
                       comments: 'Test comments',
                       start_year: 2000,
                       end_year: 2005) }

  let(:user) { create(:user, first_name: 'Jane', last_name: 'Testuser') }

  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      before { visit rails_admin.show_path(model_name: :education_history_item, id: item.id) }

      it 'shows the item detail heading' do
        expect(page).to have_content "Details for Education history item 'EducationHistoryItem ##{item.id}'"
      end

      it 'shows the user to which the item belongs' do
        expect(page).to have_link 'Jane Testuser'
      end

      it "shows the item's Activity Insight identifier" do
        expect(page).to have_content '1234567890'
      end

      it "shows the item's degree" do
        expect(page).to have_content 'Test Degree'
      end

      it "shows the item's explanation of other degree" do
        expect(page).to have_content 'Test explanation'
      end

      it 'shows if the item is an honorary degree' do
        expect(page).to have_content 'Yes honorary'
      end

      it 'shows if the item is the highest degree earned' do
        expect(page).to have_content 'Not highest'
      end

      it "shows the item's institution" do
        expect(page).to have_content 'Test Institution'
      end

      it "shows the item's school" do
        expect(page).to have_content 'Test School'
      end

      it "shows the item's institution location" do
        expect(page).to have_content 'Test Location'
      end

      it "shows the item's emphasis or major" do
        expect(page).to have_content 'Test Major'
      end

      it "shows the item's supporting areas of emphasis" do
        expect(page).to have_content 'Test areas'
      end

      it "shows the item's dissertation or thesis title" do
        expect(page).to have_content 'Test Title'
      end

      it "shows the item's honor or distinction" do
        expect(page).to have_content 'Test Honor'
      end

      it "shows the item's description" do
        expect(page).to have_content 'Test description'
      end

      it "shows the item's comments" do
        expect(page).to have_content 'Test comments'
      end

      it "shows the item's start year" do
        expect(page).to have_content '2000'
      end

      it "shows the item's end year" do
        expect(page).to have_content '2005'
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.show_path(model_name: :education_history_item, id: item.id) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.show_path(model_name: :education_history_item, id: item.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
