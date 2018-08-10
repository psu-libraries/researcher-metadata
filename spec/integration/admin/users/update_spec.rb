require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "updating a user via the admin interface", type: :feature do
  let!(:user) { create(:user, first_name: 'Bob',
                       last_name: 'Testuser',
                       webaccess_id: 'bat123') }

  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "submitting the form with new data to update a user record" do
      before do
        visit "admin/user/#{user.id}/edit"
        fill_in 'Last name', with: 'Testerson'
        click_on 'Save'
      end

      it "updates the user record's data" do
        expect(user.reload.last_name).to eq 'Testerson'
      end

      it "sets the timestamp on the user record to indicate that it was manually updated" do
        expect(user.reload.updated_by_user_at).not_to be_blank
      end
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit "admin/user/#{user.id}/edit"
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
