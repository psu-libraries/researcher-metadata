require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin email errors list', type: :feature do
  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      let!(:error1) { create(:email_error, user: u1, message: 'Message One') }
      let!(:error2) { create(:email_error, user: u2, message: 'Message Two') }

      let(:u1) { create(:user, first_name: 'First', last_name: 'User') }
      let(:u2) { create(:user, first_name: 'Second', last_name: 'User') }

      before { visit rails_admin.index_path(model_name: :email_error) }

      it 'shows the email errors list heading' do
        expect(page).to have_content 'List of Email errors'
      end

      it 'shows information about each error' do
        expect(page).to have_content error1.id
        expect(page).to have_link 'First User', href: rails_admin.show_path(model_name: :user, id: u1.id)
        expect(page).to have_content 'Message One'

        expect(page).to have_content error2.id
        expect(page).to have_link 'Second User', href: rails_admin.show_path(model_name: :user, id: u2.id)
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
      visit rails_admin.index_path(model_name: :email_error)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
