# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Deleting an Authorship', type: :feature do
  let!(:auth) { create(:authorship) }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.delete_path(model_name: :authorship, id: auth.id)
    end

    describe 'visiting the form to delete an authorship' do
      it_behaves_like 'a page with the admin layout'
      it 'show the correct content' do
        expect(page).to have_content 'Are you sure you want to delete this authorship'
      end
    end

    describe 'submitting the form to delete an authorship' do
      before do
        click_button "Yes, I'm sure"
      end

      it 'deletes the authorship' do
        expect { auth.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'redirects to the authorship list' do
        expect(page).to have_current_path rails_admin.index_path(model_name: :authorship), ignore_query: true
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.delete_path(model_name: :authorship, id: auth.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
