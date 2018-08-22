require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Creating a user", type: :feature do
  context "when the current user is an admin" do
    before do
      authenticate_admin_user
      visit 'admin/user/new'
    end

    describe "visiting the form to create a new user" do
      it_behaves_like "a page with the admin layout"
      it "show the correct content" do
        expect(page).to have_content "New User"
      end
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit 'admin/user/new'
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
