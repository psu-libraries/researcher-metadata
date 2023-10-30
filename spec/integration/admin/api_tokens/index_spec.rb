# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin API tokens list', type: :feature do
  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      let!(:token1) { create(:api_token, token: 'secret_token_1', app_name: 'A Test Application') }
      let!(:token2) { create(:api_token, token: 'secret_token_2', app_name: 'Another Application', write_access: true) }

      before { visit rails_admin.index_path(model_name: :api_token) }

      it 'shows the API token list heading' do
        expect(page).to have_content 'List of API tokens'
      end

      it 'shows information about each API token' do
        expect(page).to have_content token1.id
        expect(page).to have_content 'secret_token_1'
        expect(page).to have_content 'A Test Application'

        expect(page).to have_content token2.id
        expect(page).to have_content 'secret_token_2'
        expect(page).to have_content 'Another Application'

        expect(page).to have_css 'span.fa-check', count: 1
        expect(page).to have_css 'span.fa-times', count: 1
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.index_path(model_name: :api_token) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.index_path(model_name: :api_token)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
