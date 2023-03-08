# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin performance detail page', type: :feature do
  let!(:user1) { create(:user,
                        first_name: 'Bob',
                        last_name: 'Testuser') }
  let!(:user2) { create(:user,
                        first_name: 'Susan',
                        last_name: 'Tester') }

  let!(:performance) { create(:performance,
                              title: "Bob's Performance",
                              performance_type: 'Film - Documentary',
                              sponsor: 'Penn State',
                              description: 'This is a performance.',
                              group_name: 'Penn State Performing Group',
                              location: 'State College',
                              delivery_type: 'Invitation',
                              scope: 'Local',
                              start_on: Date.new(2018, 9, 24),
                              end_on: Date.new(2018, 9, 25)) }

  let!(:user_performance1) { create(:user_performance,
                                    performance: performance,
                                    user: user1) }

  let!(:user_performance2) { create(:user_performance,
                                    performance: performance,
                                    user: user2) }

  let!(:performance_screening1) { create(:performance_screening,
                                         performance: performance) }

  let!(:performance_screening2) { create(:performance_screening,
                                         performance: performance) }

  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      before { visit rails_admin.show_path(model_name: :performance, id: performance.id) }

      it 'shows the correct data for the performance' do
        expect(page).to have_content "Details for Performance 'Bob's Performance'"
        expect(page).to have_content "Bob's Performance"
        expect(page).to have_content 'Film - Documentary'
        expect(page).to have_content 'Penn State'
        expect(page).to have_content 'This is a performance.'
        expect(page).to have_content 'Penn State Performing Group'
        expect(page).to have_content 'State College'
        expect(page).to have_content 'Invitation'
        expect(page).to have_content 'September 24, 2018'
        expect(page).to have_content 'September 25, 2018'

        expect(page).to have_link "UserPerformance ##{user_performance1.id}"
        expect(page).to have_link "UserPerformance ##{user_performance2.id}"

        expect(page).to have_link performance_screening1.name.to_s
        expect(page).to have_link performance_screening2.name.to_s
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.show_path(model_name: :performance, id: performance.id) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.show_path(model_name: :performance, id: performance.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
