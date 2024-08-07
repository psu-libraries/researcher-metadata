# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin publication list', type: :feature do
  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      let!(:publication1) { create(:publication, title: 'Test Publication') }
      let!(:publication2) { create(:publication, title: 'Another Publication') }

      before { visit rails_admin.index_path(model_name: :publication) }

      it 'shows the publication list heading' do
        expect(page).to have_content 'List of Publications'
      end

      it 'shows information about each publication' do
        expect(page).to have_content publication1.id
        expect(page).to have_content 'Test Publication'

        expect(page).to have_content publication2.id
        expect(page).to have_content 'Another Publication'
      end

      it 'shows a link to view all publications' do
        expect(page).to have_link 'All'
      end

      it 'shows a link to scope the list by open access' do
        expect(page).to have_link 'Open Access'
      end

      it 'shows a link to scope the list by ScholarSphere open access' do
        expect(page).to have_link 'Scholarsphere Open Access'
      end

      it 'shows a link to scope the list by user provided open access' do
        expect(page).to have_link 'User Open Access'
      end

      it 'shows a link to scope the list by OAB open access' do
        expect(page).to have_link 'OAB Open Access'
      end

      it 'shows a link to scope the list by Unpaywall open access' do
        expect(page).to have_link 'Unpaywall Open Access'
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.index_path(model_name: :publication) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.index_path(model_name: :publication)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
