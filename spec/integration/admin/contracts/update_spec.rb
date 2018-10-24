require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "updating a contract via the admin interface", type: :feature do
  let!(:con) { create(:contract, visible: false) }

  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "changing the contract's visibility" do
      before do
        visit rails_admin.edit_path(model_name: :contract, id: con.id)
        check 'Visible via API?'
        click_on 'Save'
      end

      it "updates the contract's visibility" do
        expect(con.reload.visible).to eq true
      end
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.edit_path(model_name: :contract, id: con.id)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
