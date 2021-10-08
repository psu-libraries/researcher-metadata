# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Creating a user', type: :feature do
  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.new_path(model_name: :user)
    end

    describe 'visiting the form to create a new user' do
      it_behaves_like 'a page with the admin layout'
      it 'show the correct content' do
        expect(page).to have_content 'New User'
      end

      it "does not allow the new user's H-Index to be set" do
        expect(page).not_to have_field 'H-Index'
        expect(page).not_to have_field 'Scopus h index'
      end
    end

    describe 'submitting the form to create a new user' do
      before do
        fill_in 'Penn State WebAccess ID', with: 'abc123'
        fill_in 'First name', with: 'Test'
        fill_in 'Middle name', with: 'N'
        fill_in 'Last name', with: 'User'
        fill_in 'Pure ID', with: 'pure-12345'
        fill_in 'Activity Insight ID', with: 'ai-67890'
        fill_in 'Penn State ID', with: '9999999'
        check 'Admin user?'
        check 'Show all publications'
        check 'Show all contracts'
        click_button 'Save'
      end

      it 'creates a new user record in the database with the provided data' do
        u = User.find_by(webaccess_id: 'abc123')

        expect(u.first_name).to eq 'Test'
        expect(u.middle_name).to eq 'N'
        expect(u.last_name).to eq 'User'
        expect(u.pure_uuid).to eq 'pure-12345'
        expect(u.activity_insight_identifier).to eq 'ai-67890'
        expect(u.penn_state_identifier).to eq '9999999'
        expect(u.is_admin).to eq true
        expect(u.show_all_publications).to eq true
        expect(u.show_all_contracts).to eq true
      end

      it 'marks the new user as having been manually edited' do
        u = User.find_by(webaccess_id: 'abc123')

        expect(u.updated_by_user_at).not_to be_nil
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.new_path(model_name: :user)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
