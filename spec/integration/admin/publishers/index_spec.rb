require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin publishers list", type: :feature do
  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "the page content" do
      let!(:publisher1) { create(:publisher, name: 'First Publisher') }
      let!(:publisher2) { create(:publisher, name: 'Second Publisher') }

      before { visit rails_admin.index_path(model_name: :publisher) }

      it "shows the publisher list heading" do
        expect(page).to have_content 'List of Publishers'
      end

      it "shows information about each publisher" do
        expect(page).to have_content publisher1.id
        expect(page).to have_content 'First Publisher'

        expect(page).to have_content publisher2.id
        expect(page).to have_content 'Second Publisher'

        within '.table' do
          expect(page).to have_content 'Publication count'
        end
      end

      it "shows a link to sort the list by number of publications" do
        expect(page).to have_link "Ordered By Publication Count",
                                  href: rails_admin.index_path(model_name: :publisher, params: {model_name: :publisher, scope: :ordered_by_publication_count})
      end
    end

    describe "the page layout" do
      before { visit rails_admin.index_path(model_name: :publisher) }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.index_path(model_name: :publisher)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
