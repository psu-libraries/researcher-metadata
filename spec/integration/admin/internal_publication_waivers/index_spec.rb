# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin internal publication waivers list', type: :feature do
  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      let!(:waiver1) { create(:internal_publication_waiver, authorship: auth1) }
      let!(:waiver2) { create(:internal_publication_waiver, authorship: auth2) }
      let!(:auth1) { create(:authorship, publication: pub1, user: user1) }
      let!(:auth2) { create(:authorship, publication: pub2, user: user2) }
      let!(:user1) { create(:user, first_name: 'Joe', last_name: 'Testerson') }
      let!(:user2) { create(:user, first_name: 'Beth', last_name: 'Testuser') }
      let!(:pub1) { create(:publication, title: 'Publication One') }
      let!(:pub2) { create(:publication, title: 'Publication Two') }

      before { visit rails_admin.index_path(model_name: :internal_publication_waiver) }

      it 'shows the waiver list heading' do
        expect(page).to have_content 'List of Internal publication waivers'
      end

      it 'shows information about each waiver' do
        expect(page).to have_content waiver1.id
        expect(page).to have_content 'Joe Testerson'
        expect(page).to have_content 'Publication One'

        expect(page).to have_content waiver2.id
        expect(page).to have_content 'Beth Testuser'
        expect(page).to have_content 'Publication Two'
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.index_path(model_name: :internal_publication_waiver) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.index_path(model_name: :internal_publication_waiver)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
