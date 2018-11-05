require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin dashboard", type: :feature do

  context "when the current user is an admin" do
    before do
      authenticate_admin_user
    end

    describe "the page content" do
      before do
        4.times { create :contract }
        4.times { create :publication }
        4.times { create :user }
        3.times { create :duplicate_publication_group }
        7.times { create :presentation }
        8.times { create :etd }
        2.times { create :organization }

        visit rails_admin.dashboard_path
      end

      it "shows the dashboard heading" do
        expect(page).to have_content 'Dashboard'
      end

      it "shows a count of the records in the database" do
        within 'tr.contract_links' do
          expect(page).to have_content '4'
        end

        within 'tr.publication_links' do
          expect(page).to have_content '4'
        end

        within 'tr.user_links' do
          expect(page).to have_content '5'
        end

        within 'tr.duplicate_publication_group_links' do
          expect(page).to have_content '3'
        end

        within 'tr.presentation_links' do
          expect(page).to have_content '7'
        end

        within 'tr.etd_links' do
          expect(page).to have_content '8'
        end

        within 'tr.organization_links' do
          expect(page).to have_content '2'
        end
      end
    end

    describe "the page layout" do
      before { visit rails_admin.dashboard_path }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.dashboard_path
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
