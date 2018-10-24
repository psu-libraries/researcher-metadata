require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin contracts list", type: :feature do
  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "the page content" do
      let!(:contract1) { create(:contract, title: 'Test Contract') }
      let!(:contract2) { create(:contract, title: 'Another Contract') }

      before { visit rails_admin.index_path(model_name: :contract) }

      it "shows the contract list heading" do
        expect(page).to have_content 'List of Contracts'
      end

      it "shows information about each contract" do
        expect(page).to have_content contract1.id
        expect(page).to have_content 'Test Contract'

        expect(page).to have_content contract2.id
        expect(page).to have_content 'Another Contract'
      end
    end

    describe "the page layout" do
      before { visit rails_admin.index_path(model_name: :contract) }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.index_path(model_name: :contract)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
