require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin authorships list", type: :feature do
  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "the page content" do
      let!(:auth1) { create(:authorship) }
      let!(:auth2) { create(:authorship) }

      before { visit rails_admin.index_path(model_name: :authorship) }

      it "shows the authorship list heading" do
        expect(page).to have_content 'List of Authorships'
      end

      it "shows information about each authorship" do
        expect(page).to have_content auth1.id

        expect(page).to have_content auth2.id
      end
    end

    describe "the page layout" do
      before { visit rails_admin.index_path(model_name: :authorship) }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.index_path(model_name: :authorship)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
