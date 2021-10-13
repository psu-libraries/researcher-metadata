# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin importer log errors list', type: :feature do
  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      let!(:error1) { create(:importer_error_log, error_message: 'Message One') }
      let!(:error2) { create(:importer_error_log, error_message: 'Message Two') }

      before { visit rails_admin.index_path(model_name: :importer_error_log) }

      it 'shows information about each error' do
        expect(page).to have_content 'Message One'
        expect(page).to have_content 'Message Two'
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.index_path(model_name: :email_error) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.index_path(model_name: :importer_error_log)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
