require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin external publication waivers list", type: :feature do
  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "the page content" do
      let!(:waiver1) { create :external_publication_waiver,
                              user: user1,
                              publication_title: "Publication One" }
      let!(:waiver2) { create :external_publication_waiver,
                              user: user2,
                              publication_title: "Publication Two" }
      let!(:waiver3) { create :external_publication_waiver,
                              user: user3,
                              publication_title: "Publication Three",
                              internal_publication_waiver: int_waiver }
      let!(:user1) { create :user, first_name: "Joe", last_name: "Testerson" }
      let!(:user2) { create :user, first_name: "Beth", last_name: "Testuser" }
      let!(:user3) { create :user, first_name: "Felix", last_name: "Tester" }

      let!(:int_waiver) { create :internal_publication_waiver }
      
      before { visit rails_admin.index_path(model_name: :external_publication_waiver) }

      it "shows the waiver list heading" do
        expect(page).to have_content 'List of External publication waivers'
      end

      it "shows information about each waiver" do
        expect(page).to have_content waiver1.id
        expect(page).to have_content 'Joe Testerson'
        expect(page).to have_content 'Publication One'

        expect(page).to have_content waiver2.id
        expect(page).to have_content 'Beth Testuser'
        expect(page).to have_content 'Publication Two'
      end

      it "does not show waivers that have been linked to publications" do
        expect(page).not_to have_content 'Felix Tester'
        expect(page).not_to have_content 'Publication Three'
      end
    end

    describe "the page layout" do
      before { visit rails_admin.index_path(model_name: :external_publication_waiver) }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.index_path(model_name: :external_publication_waiver)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
