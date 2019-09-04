require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin grant detail page", type: :feature do
  let!(:grant) { create :grant,
                        agency_name: "Test Agency",
                        identifier: "GRANT-ID-123"}
  let!(:pub1) { create :publication, title: "Publication1" }
  let!(:pub2) { create :publication, title: "Publication2" }
  let!(:rf1) { create :research_fund,
                      grant: grant,
                      publication: pub1 }
  let!(:rf2) { create :research_fund,
                      grant: grant,
                      publication: pub2 }

  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "the page content" do
      before { visit rails_admin.show_path(model_name: :grant, id: grant.id) }

      it "shows the grant detail heading" do
        expect(page).to have_content "Details for Grant 'GRANT-ID-123'"
      end

      it "shows the grant's agency" do
        expect(page).to have_content "Test Agency"
      end

      it "shows the grant's identifier" do
        expect(page).to have_content "GRANT-ID-123"
      end

      it "shows the grant's publications" do
        expect(page).to have_link "Publication1"
        expect(page).to have_link "Publication2"
      end
    end

    describe "the page layout" do
      before { visit rails_admin.show_path(model_name: :grant, id: grant.id) }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.show_path(model_name: :grant, id: grant.id)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
