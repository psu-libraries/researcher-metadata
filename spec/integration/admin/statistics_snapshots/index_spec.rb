require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin statistics snapshots list", type: :feature do
  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "the page content" do
      let!(:stats1) { create(:statistics_snapshot,
                             total_publication_count: 3859,
                             open_access_publication_count: 1035,
                             created_at: Time.new(2021, 1, 21, 23, 39, 0, 0)) }
      let!(:stats2) { create(:statistics_snapshot,
                             total_publication_count: 8743,
                             open_access_publication_count: 3765,
                             created_at: Time.new(2001, 4, 1, 9, 4, 0, 0)) }

      before { visit rails_admin.index_path(model_name: :statistics_snapshot) }

      it "shows the statistics snapshots list heading" do
        expect(page).to have_content 'List of Statistics snapshots'
      end

      it "shows information about each snapshot" do
        expect(page).to have_content 3859
        expect(page).to have_content 1035

        expect(page).to have_content 8743
        expect(page).to have_content 3765

        expect(page).to have_content 26.8
        expect(page).to have_content 43.1

        expect(page).to have_content "January 21, 2021 23:39"
        expect(page).to have_content "April 01, 2001 09:04"
      end
    end

    describe "the page layout" do
      before { visit rails_admin.index_path(model_name: :statistics_snapshot) }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.index_path(model_name: :statistics_snapshot)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
