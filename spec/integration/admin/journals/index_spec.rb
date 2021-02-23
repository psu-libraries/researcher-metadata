require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin journals list", type: :feature do
  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "the page content" do
      let!(:journal1) { create(:journal, title: 'First Journal') }
      let!(:journal2) { create(:journal, title: 'Second Journal') }

      before { visit rails_admin.index_path(model_name: :journal) }

      it "shows the journal list heading" do
        expect(page).to have_content 'List of Journals'
      end

      it "shows information about each journal" do
        expect(page).to have_content journal1.id
        expect(page).to have_content 'First Journal'

        expect(page).to have_content journal2.id
        expect(page).to have_content 'Second Journal'

        within '.table' do
          expect(page).to have_content 'Publication count'
        end
      end

      it "shows a link to sort the list by number of publications" do
        expect(page).to have_link "Ordered By Publication Count",
                                  href: rails_admin.index_path(model_name: :journal, params: {model_name: :journal, scope: :ordered_by_publication_count})
      end

      it "shows a link to sort the list by number of Penn State publications" do
        expect(page).to have_link "Ordered By PSU Publication Count",
                                  href: rails_admin.index_path(model_name: :journal, params: {model_name: :journal, scope: :ordered_by_psu_publication_count})
      end
    end

    describe "the page layout" do
      before { visit rails_admin.index_path(model_name: :journal) }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.index_path(model_name: :journal)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
