# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin user list', type: :feature do
  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      let!(:user1) { create(:user, first_name: 'Bob', last_name: 'Testuser', webaccess_id: 'bob') }
      let!(:user2) { create(:user, first_name: 'Susan', last_name: 'Tester', webaccess_id: 'sue') }

      before { visit rails_admin.index_path(model_name: :user) }

      it 'shows the user list heading' do
        expect(page).to have_content 'List of Users'
      end

      it 'has a tab for "Active" users' do
        expect(page).to have_link('Active', href: '/admin/user?model_name=user&scope=active')
      end

      it 'shows information about each user' do
        expect(page).to have_content user1.id
        expect(page).to have_content 'Bob'
        expect(page).to have_content 'Testuser'

        expect(page).to have_content user2.id
        expect(page).to have_content 'Susan'
        expect(page).to have_content 'Tester'
      end

      it 'shows their status' do
        visit rails_admin.index_path(model_name: :user, set: 1)
        expect(page).to have_content 'Active?'
      end

      it "shows links to each user's public profile page" do
        expect(page).to have_link('bob', href: '/profiles/bob')
        expect(page).to have_link('sue', href: '/profiles/sue')
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.index_path(model_name: :user) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.index_path(model_name: :user)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
