require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin email error detail page', type: :feature do
  let!(:error) { create :email_error,
                        user: u,
                        message: 'Test Message' }

  let!(:u) { create :user, first_name: 'Test', last_name: 'User' }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
    end

    describe 'the page content' do
      before { visit rails_admin.show_path(model_name: :email_error, id: error.id) }

      it 'shows the user with which the error is associated' do
        expect(page).to have_link 'Test User', href: rails_admin.show_path(model_name: :user, id: u.id)
      end

      it 'shows the error message' do
        expect(page).to have_content 'Test Message'
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.show_path(model_name: :email_error, id: error.id) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.show_path(model_name: :email_error, id: error.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
