require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin duplicate publication group list', type: :feature do
  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      let!(:group1) { create :duplicate_publication_group }
      let!(:group2) { create :duplicate_publication_group }

      before { visit rails_admin.index_path(model_name: :duplicate_publication_group) }

      it 'shows the duplicate publication group list heading' do
        expect(page).to have_content 'List of Duplicate publication groups'
      end

      it 'shows information about each group' do
        expect(page).to have_content group1.id

        expect(page).to have_content group2.id
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.index_path(model_name: :duplicate_publication_group) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.index_path(model_name: :duplicate_publication_group)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
