require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin grant detail page", type: :feature do
  let!(:grant) { create :grant,
                        wos_agency_name: "Test Agency",
                        wos_identifier: "GRANT-ID-123",
                        title: "Test Grant",
                        abstract: "A description of the grant.",
                        start_date: Date.new(2000, 1, 1),
                        end_date: Date.new(2005, 2, 20), amount_in_dollars: 50123 }
  let!(:pub1) { create :publication, title: "Publication1" }
  let!(:pub2) { create :publication, title: "Publication2" }
  let!(:user1) { create :user, first_name: "Test", last_name: "User1" }
  let!(:user2) { create :user, first_name: "Test", last_name: "User2" }
  let!(:rf1) { create :research_fund,
                      grant: grant,
                      publication: pub1 }
  let!(:rf2) { create :research_fund,
                      grant: grant,
                      publication: pub2 }
  let!(:f1) { create :researcher_fund, grant: grant, user: user1 }
  let!(:f2) { create :researcher_fund, grant: grant, user: user2 }

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

      it "shows the grant's title" do
        expect(page).to have_content "Test Grant"
      end

      it "shows the grant's abstract" do
        expect(page).to have_content "A description of the grant."
      end

      it "shows the grant's start date" do
        expect(page).to have_content "January 01, 2000"
      end

      it "shows the grant's end date" do
        expect(page).to have_content "February 20, 2005"
      end

      it "shows the grant's dollar amount" do
        expect(page).to have_content "50123"
      end

      it "shows the grant's publications" do
        expect(page).to have_link "Publication1"
        expect(page).to have_link "Publication2"
      end

      it "shows the grant's users" do
        expect(page).to have_link "Test User1"
        expect(page).to have_link "Test User2"
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
