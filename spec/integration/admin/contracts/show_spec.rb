require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin contract detail page", type: :feature do
  let!(:user1) { create(:user,
                        first_name: 'Bob',
                        last_name: 'Testuser') }
  let!(:user2) { create(:user,
                        first_name: 'Susan',
                        last_name: 'Tester') }

  let!(:con) { create :contract,
                      title: "Bob's Contract",
                      contract_type: 'Grant',
                      sponsor: 'Sponsoring Organization',
                      status: 'Awarded',
                      amount: 12345,
                      ospkey: 98765 }

  let!(:uc1) { create :user_contract,
                     contract: con,
                     user: user1 }

  let!(:uc2) { create :user_contract,
                     contract: con,
                     user: user2 }

  let!(:imp1) { create :contract_import,
                       contract: con }

  let!(:imp2) { create :contract_import,
                       contract: con }

  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "the page content" do
      before { visit rails_admin.show_path(model_name: :contract, id: con.id) }

      it "shows the contract detail heading" do
        expect(page).to have_content "Details for Contract 'Bob's Contract'"
      end

      it "shows the contract's type" do
        expect(page).to have_content "Grant"
      end

      it "shows the contract's sponsor" do
        expect(page).to have_content "Sponsoring Organization"
      end

      it "shows the contract's status" do
        expect(page).to have_content "Awarded"
      end

      it "shows the contract's amount" do
        expect(page).to have_content "12345"
      end

      it "shows the contract's ospkey" do
        expect(page).to have_content "98765"
      end

      it "shows the contract's user associations" do
        expect(page).to have_link "UserContract ##{uc1.id}"
        expect(page).to have_link "UserContract ##{uc2.id}"
      end

      it "shows the contract's users" do
        expect(page).to have_link "Bob Testuser"
        expect(page).to have_link "Susan Tester"
      end

      it "shows the contract's imports" do
        expect(page).to have_link "ContractImport ##{imp1.id}"
        expect(page).to have_link "ContractImport ##{imp2.id}"
      end
    end

    describe "the page layout" do
      before { visit rails_admin.show_path(model_name: :contract, id: con.id) }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.show_path(model_name: :contract, id: con.id)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
