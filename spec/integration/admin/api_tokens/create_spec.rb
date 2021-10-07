require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Creating an API Token', type: :feature do
  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.new_path(model_name: :api_token)
    end

    describe 'visiting the form to create a new API Token' do
      it_behaves_like 'a page with the admin layout'
      it 'show the correct content' do
        expect(page).to have_content 'New API token'
      end

      it "does not allow the new token's value to be set" do
        expect(page).not_to have_field 'Token'
      end

      it "does not allow the new token's total requests to be set" do
        expect(page).not_to have_field 'Total requests'
      end
    end

    describe 'submitting the form to create a new API Token' do
      before do
        fill_in 'App name', with: 'Test App'
        fill_in 'Admin email', with: 'test@email.com'

        click_button 'Save'
      end

      it 'creates a new API Token record in the database with the provided data' do
        t = APIToken.find_by(admin_email: 'test@email.com')

        expect(t.token).not_to be_blank
        expect(t.app_name).to eq 'Test App'
        expect(t.total_requests).to eq 0
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.new_path(model_name: :api_token)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
