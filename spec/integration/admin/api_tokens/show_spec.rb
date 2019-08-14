require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin API token detail page", type: :feature do
  let!(:token) { create :api_token,
                        token: 'secret_token_1',
                        app_name: "Test Application",
                        admin_email: 'admin123@psu.edu' }

  let!(:org1) { create :organization, name: 'Organization One' }
  let!(:org2) { create :organization, name: 'Organization Two' }

  context "when the current user is an admin" do
    before do
      create :organization_api_permission, api_token: token, organization: org1
      create :organization_api_permission, api_token: token, organization: org2
      authenticate_admin_user
    end

    describe "the page content" do
      before { visit rails_admin.show_path(model_name: :api_token, id: token.id) }

      it "shows the token's value" do
        expect(page).to have_content "secret_token_1"
      end

      it "shows the token's app name" do
        expect(page).to have_content "Test Application"
      end

      it "shows the token's administrator email" do
        expect(page).to have_content "admin123@psu.edu"
      end

      it "shows the token's organizations" do
        expect(page).to have_link "Organization One"
        expect(page).to have_link "Organization Two"
      end
    end

    describe "the page layout" do
      before { visit rails_admin.show_path(model_name: :api_token, id: token.id) }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.show_path(model_name: :api_token, id: token.id)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
