# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin statistics snapshot detail page', type: :feature do
  let!(:stats) { create(:statistics_snapshot,
                        total_article_count: 3841,
                        open_access_article_count: 592,
                        created_at: Time.new(2021, 1, 21, 23, 39, 0, 0)) }

  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      before { visit rails_admin.show_path(model_name: :statistics_snapshot, id: stats.id) }

      it 'shows the correct data for the snapshot' do
        expect(page).to have_content 'Details for Statistics snapshot'
        expect(page).to have_content 3841
        expect(page).to have_content 592
        expect(page).to have_content 15.4
        expect(page).to have_content 'January 21, 2021 23:39'
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.show_path(model_name: :statistics_snapshot, id: stats.id) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.show_path(model_name: :statistics_snapshot, id: stats.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
