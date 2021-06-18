require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin ScholarSphere file upload detail page", type: :feature do
  let!(:upload) { create :scholarsphere_file_upload,
                         work_deposit: deposit }
  let!(:deposit) { create :scholarsphere_work_deposit, title: 'Test Deposit' }

  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "the page content" do
      before { visit rails_admin.show_path(model_name: :scholarsphere_file_upload, id: upload.id) }

      it "shows a link to the associated deposit" do
        expect(page).to have_link "Test Deposit",
                                  href: rails_admin.show_path(model_name: :scholarsphere_work_deposit, id: deposit.id)
      end

      it "shows the upload's file" do
        expect(page).to have_content "test_file.pdf"
      end
    end

    describe "the page layout" do
      before { visit rails_admin.show_path(model_name: :scholarsphere_work_deposit, id: deposit.id) }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.show_path(model_name: :scholarsphere_file_upload, id: upload.id)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
