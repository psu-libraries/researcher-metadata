# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin authorship detail page', type: :feature do
  let!(:user) do
    create(:user,
           first_name: 'Bob',
           last_name: 'Testuser')
  end

  let!(:pub) { create(:publication, title: 'A Test Publication') }

  let!(:auth) do
    create(:authorship,
           publication: pub,
           user: user,
           author_number: 5)
  end

  let!(:dep) { create(:scholarsphere_work_deposit, title: 'Test Deposit', authorship: auth) }

  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      before { visit rails_admin.show_path(model_name: :authorship, id: auth.id) }

      it 'shows the correct data for the authorship' do
        expect(page).to have_content "Details for Authorship '##{auth.id} (Bob Testuser - A Test Publication)'"
        expect(page).to have_link 'A Test Publication', href: rails_admin.show_path(model_name: :publication, id: pub.id)
        expect(page).to have_link 'Bob Testuser', href: rails_admin.show_path(model_name: :user, id: user.id)
        expect(page).to have_content '5'
        expect(page).to have_link(
          'Test Deposit',
          href: rails_admin.show_path(model_name: :scholarsphere_work_deposit, id: dep.id)
        )
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.show_path(model_name: :authorhsip, id: auth.id) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.show_path(model_name: :authorship, id: auth.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
