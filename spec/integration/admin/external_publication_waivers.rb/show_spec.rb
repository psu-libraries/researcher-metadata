require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin external publication waiver detail page", type: :feature do
  let!(:waiver) { create :external_publication_waiver,
                         user: user,
                         publication_title: "Publication One",
                         reason_for_waiver: "Just because.",
                         abstract: "What this publication is all about.",
                         doi: "https://doi.org/the-doi",
                         journal_title: "Test Journal",
                         publisher: "Test Publisher" }
  let!(:user) { create :user, first_name: "Joe", last_name: "Testerson" }

  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "the page content" do
      before { visit rails_admin.show_path(model_name: :external_publication_waiver, id: waiver.id) }

      it "shows the waiver detail heading" do
        expect(page).to have_content "Details for External publication waiver 'Publication One'"
      end

      it "shows the title of the publication associated with the waiver" do
        expect(page).to have_content "Publication One"
      end

      it "shows the reason for the waiver" do
        expect(page).to have_content "Just because."
      end

      it "shows the publication's abstract" do
        expect(page).to have_content "What this publication is all about."
      end

      it "shows the publication's doi" do
        expect(page).to have_content "https://doi.org/the-doi"
      end

      it "shows the publication's journal title" do
        expect(page).to have_content "Test Journal"
      end

      it "shows the publication's publisher" do
        expect(page).to have_content "Test Publisher"
      end

      it "shows the name of the user associated with the waiver" do
        expect(page).to have_link "Joe Testerson", href: rails_admin.show_path(model_name: :user, id: user.id)
      end
    end

    describe "the page layout" do
      before { visit rails_admin.show_path(model_name: :external_publication_waiver, id: waiver.id) }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.show_path(model_name: :external_publication_waiver, id: waiver.id)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
