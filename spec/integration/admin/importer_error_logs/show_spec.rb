# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin importer log bunerror detail page', type: :feature do
  let!(:error) { create :importer_error_log, error_message: 'Test Message', metadata: { 'key' => 'val' }, stacktrace: '["stack", "trace"]' }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
    end

    describe 'the page content' do
      before { visit rails_admin.show_path(model_name: :importer_error_log, id: error.id) }

      it 'shows the error message' do
        expect(page).to have_content 'Test Message'
      end

      it 'shows the metadata' do
        expect(page).to have_content '"key": "val"'
      end

      it 'shows the stack trace' do
        expect(page.html).to include "<pre>stack\ntrace</pre>"
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.show_path(model_name: :importer_error_log, id: error.id) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.show_path(model_name: :importer_error_log, id: error.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
