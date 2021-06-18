require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin ScholarSphere work deposit detail page", type: :feature do
  let!(:deposit) { create :scholarsphere_work_deposit,
                          authorship: auth,
                          status: 'Success',
                          error_message: 'No errors occurred.',
                          deposited_at: Time.new(2021, 4, 2, 16, 46, 0),
                          title: 'Test Work',
                          description: 'A description',
                          published_date: Date.new(2020, 12, 20),
                          embargoed_until: Date.new(2022, 1, 1),
                          rights: 'https://rightsstatements.org/page/InC/1.0/' }
  let!(:auth) { create :authorship }
  let!(:upload) { create :scholarsphere_file_upload, work_deposit: deposit }

  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "the page content" do
      before { visit rails_admin.show_path(model_name: :scholarsphere_work_deposit, id: deposit.id) }

      it "shows a link to the associated authorship" do
        expect(page).to have_link "##{auth.id} (Test User - Test)", href: rails_admin.show_path(model_name: :authorship, id: auth.id)
      end

      it "shows the deposit's status" do
        expect(page).to have_content "Status"
      end

      it "shows the deposit's error message" do
        expect(page).to have_content "No errors occurred."
      end

      it "shows the deposit's time of deposit" do
        expect(page).to have_content "April 02, 2021 20:46"
      end

      it "shows the deposit's title" do
        expect(page).to have_content "Test Work"
      end

      it "shows the deposit's description" do
        expect(page).to have_content "A description"
      end

      it "shows the deposit's date of publish" do
        expect(page).to have_content "December 20, 2020"
      end

      it "shows the date when the deposit's embargo is set to end" do
        expect(page).to have_content "January 01, 2022"
      end

      it "shows the deposit's license" do
        expect(page).to have_content "https://rightsstatements.org/page/InC/1.0/"
      end

      it "shows links to the deposit's file uploads" do
        expect(page).to have_link "ScholarsphereFileUpload ##{upload.id}",
                                  href: rails_admin.show_path(model_name: :scholarsphere_file_upload, id: upload.id)
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
      visit rails_admin.show_path(model_name: :scholarsphere_work_deposit, id: deposit.id)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
