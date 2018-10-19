require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin organization detail page", type: :feature do
  let!(:org) { create :organization,
                      pure_uuid: 'pure-uuid-001',
                      name: 'Test Org',
                      organization_type: 'College',
                      pure_external_identifier: 'EXT-ID',
                      parent: parent_org }

  let(:parent_org) { create :organization, name: 'Test Parent Org' }
  let!(:child_org1) { create :organization, name: 'Test Child Org 1', parent: org }
  let!(:child_org2) { create :organization, name: 'Test Child Org 2', parent: org }

  context "when the current user is an admin" do
    before do
      authenticate_admin_user
    end

    describe "the page content" do
      before { visit rails_admin.show_path(model_name: :organization, id: org.id) }

      it "shows the organization detail heading" do
        expect(page).to have_content "Details for Organization 'Test Org'"
      end

      it "shows the organization's pure UUID" do
        expect(page).to have_content "pure-uuid-001"
      end

      it "shows the organization's type" do
        expect(page).to have_content "College"
      end

      it "shows the organization's Pure external identifier" do
        expect(page).to have_content "EXT-ID"
      end

      it "shows a link to the organization's parent organization" do
        expect(page).to have_link "Test Parent Org"
      end

      it "shows links to the organization's child organizations" do
        expect(page).to have_link "Test Child Org 1"
        expect(page).to have_link "Test Child Org 2"
      end
    end

    describe "the page layout" do
      before { visit rails_admin.show_path(model_name: :organization, id: org.id) }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.show_path(model_name: :organization, id: org.id)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
