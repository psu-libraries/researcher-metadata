require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin duplicate publication group detail page", type: :feature do
  let!(:pub1) { create :publication, title: "Duplicate Publication", duplicate_group: group }
  let!(:pub2) { create :publication, title: "A duplicate publication", duplicate_group: group }

  let(:group) { create :duplicate_publication_group }

  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "the page content" do
      before { visit "admin/duplicate_publication_group/#{group.id}" }

      it "shows the titles of the publications in the group" do
        expect(page).to have_link "Duplicate Publication"
        expect(page).to have_link "A duplicate publication"
      end
    end

    describe "the page layout" do
      before { visit "admin/duplicate_publication_group/#{group.id}" }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit "admin/duplicate_publication_group/#{group.id}"
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
