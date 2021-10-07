require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin presentations list', type: :feature do
  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      let!(:pres1) { create(:presentation, title: 'Test Presentation') }
      let!(:pres2) { create(:presentation, title: 'Another Presentation') }

      before { visit rails_admin.index_path(model_name: :presentation) }

      it 'shows the presentation list heading' do
        expect(page).to have_content 'List of Presentations'
      end

      it 'shows information about each presentation' do
        expect(page).to have_content pres1.id
        expect(page).to have_content 'Test Presentation'

        expect(page).to have_content pres2.id
        expect(page).to have_content 'Another Presentation'
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.index_path(model_name: :presentation) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.index_path(model_name: :presentation)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
