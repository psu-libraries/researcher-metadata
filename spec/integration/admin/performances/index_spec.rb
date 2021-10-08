# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin performances list', type: :feature do
  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      let!(:performance1) { create(:performance, title: 'Test Performance') }
      let!(:performance2) { create(:performance, title: 'Another Performance') }

      before { visit rails_admin.index_path(model_name: :performance) }

      it 'shows the performance list heading' do
        expect(page).to have_content 'List of Performances'
      end

      it 'shows information about each performance' do
        expect(page).to have_content performance1.id
        expect(page).to have_content 'Test Performance'

        expect(page).to have_content performance2.id
        expect(page).to have_content 'Another Performance'
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.index_path(model_name: :performance) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.index_path(model_name: :performance)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
