require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin grants list", type: :feature do
  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "the page content" do
      let!(:grant1) { create(:grant, wos_agency_name: 'Test Grant Agency') }
      let!(:grant2) { create(:grant, wos_agency_name: 'Another Grant Agency') }

      before { visit rails_admin.index_path(model_name: :grant) }

      it "shows the grant list heading" do
        expect(page).to have_content 'List of Grants'
      end

      it "shows information about each grant" do
        expect(page).to have_content grant1.id
        expect(page).to have_content 'Test Grant Agency'

        expect(page).to have_content grant2.id
        expect(page).to have_content 'Another Grant Agency'
      end
    end

    describe "the page layout" do
      before { visit rails_admin.index_path(model_name: :grant) }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.index_path(model_name: :grant)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
