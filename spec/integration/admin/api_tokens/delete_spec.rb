# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Deleting an API Token', type: :feature do
  let!(:token) { create :api_token }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.delete_path(model_name: :api_token, id: token.id)
    end

    describe 'visiting the form to delete an API Token' do
      it_behaves_like 'a page with the admin layout'
      it 'show the correct content' do
        expect(page).to have_content 'Are you sure you want to delete this api token'
      end
    end

    describe 'submitting the form to delete an API Token' do
      before do
        click_button "Yes, I'm sure"
      end

      it 'deletes the API token' do
        expect { token.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.delete_path(model_name: :api_token, id: token.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
