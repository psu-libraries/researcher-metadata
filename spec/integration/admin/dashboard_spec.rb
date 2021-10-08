# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin dashboard', type: :feature do
  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
    end

    describe 'the page content' do
      before do
        create_list :publication, 3
        create_list :user, 3
        create_list :duplicate_publication_group, 3
        create_list :presentation, 7
        create_list :etd, 8
        create_list :organization, 2
        create_list :performance, 6
        create_list :grant, 5

        visit rails_admin.dashboard_path
      end

      it 'shows the dashboard heading' do
        expect(page).to have_content 'Dashboard'
      end

      it 'shows a count of the records in the database' do
        within 'tr.publication_links' do
          expect(page).to have_content '3'
        end

        within 'tr.user_links' do
          expect(page).to have_content '4'
        end

        within 'tr.duplicate_publication_group_links' do
          expect(page).to have_content '3'
        end

        within 'tr.presentation_links' do
          expect(page).to have_content '7'
        end

        within 'tr.etd_links' do
          expect(page).to have_content '8'
        end

        within 'tr.organization_links' do
          expect(page).to have_content '2'
        end

        within 'tr.performance_links' do
          expect(page).to have_content '6'
        end

        within 'tr.grant_links' do
          expect(page).to have_content '5'
        end
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.dashboard_path }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.dashboard_path
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
