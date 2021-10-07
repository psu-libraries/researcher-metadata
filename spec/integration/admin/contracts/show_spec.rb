require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin contract detail page', type: :feature do
  let!(:user1) { create(:user,
                        first_name: 'Bob',
                        last_name: 'Testuser') }
  let!(:user2) { create(:user,
                        first_name: 'Susan',
                        last_name: 'Tester') }

  let!(:contract) { create :contract,
                           title: "Bob's Contract",
                           contract_type: 'Grant',
                           sponsor: 'Government Organization',
                           status: 'Awarded',
                           amount: 10000,
                           ospkey: 123456,
                           award_start_on: Date.new(2018, 9, 24),
                           award_end_on: Date.new(2018, 9, 25) }

  let!(:user_contract1) { create :user_contract,
                                 contract: contract,
                                 user: user1 }

  let!(:user_contract2) { create :user_contract,
                                 contract: contract,
                                 user: user2 }

  let!(:imp1) { create :contract_import,
                       activity_insight_id: 7654321,
                       contract: contract }

  let!(:imp2) { create :contract_import,
                       activity_insight_id: 8765432,
                       contract: contract }

  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      before { visit rails_admin.show_path(model_name: :contract, id: contract.id) }

      it 'shows the contract detail heading' do
        expect(page).to have_content "Details for Contract 'Bob's Contract'"
      end

      it "shows the contract's title" do
        expect(page).to have_content "Bob's Contract"
      end

      it "shows the contract's contract type" do
        expect(page).to have_content 'Grant'
      end

      it "shows the contract's sponsor" do
        expect(page).to have_content 'Government Organization'
      end

      it "shows the contract's status" do
        expect(page).to have_content 'Awarded'
      end

      it "shows the contract's amount" do
        expect(page).to have_content '10000'
      end

      it "shows the contract's ospkey" do
        expect(page).to have_content '123456'
      end

      it "shows the contract's award start on date" do
        expect(page).to have_content 'September 24, 2018'
      end

      it "shows the contract's award end on date" do
        expect(page).to have_content 'September 25, 2018'
      end

      it "shows the contract's user_contracts" do
        expect(page).to have_link "UserContract ##{user_contract1.id}"
        expect(page).to have_link "UserContract ##{user_contract2.id}"
      end

      it "shows the contract's contract imports" do
        expect(page).to have_link "ContractImport ##{imp1.id}"
        expect(page).to have_link "ContractImport ##{imp2.id}"
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.show_path(model_name: :contract, id: contract.id) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.show_path(model_name: :contract, id: contract.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
