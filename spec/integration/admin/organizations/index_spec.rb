require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin organizations list", type: :feature do
  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "the page content" do
      let!(:org1) { create(:organization, name: 'Test Org') }
      let!(:org2) { create(:organization, name: 'Another Org') }

      before { visit rails_admin.index_path(model_name: :organization) }

      it "shows the organization list heading" do
        expect(page).to have_content 'List of Organizations'
      end

      it "shows information about each organization" do
        expect(page).to have_content org1.id
        expect(page).to have_content 'Test Org'

        expect(page).to have_content org2.id
        expect(page).to have_content 'Another Org'
      end
    end

    describe "the page layout" do
      before { visit rails_admin.index_path(model_name: :organization) }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.index_path(model_name: :organization)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
