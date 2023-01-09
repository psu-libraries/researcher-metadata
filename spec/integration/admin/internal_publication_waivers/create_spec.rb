# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Creating an internal publication waiver', type: :feature do
  context 'when the current user is an admin' do
    let!(:auth) { create(:authorship) }

    before do
      authenticate_admin_user
      visit rails_admin.new_path(model_name: :internal_publication_waiver)
    end

    describe 'visiting the form to create a new waiver' do
      it_behaves_like 'a page with the admin layout'
      it 'show the correct content' do
        expect(page).to have_content 'New Internal publication waiver'
      end
    end

    describe 'submitting the form to create a new waiver' do
      before do
        select auth.id, from: 'Authorship'
        fill_in 'Reason for waiver', with: 'no good reason'
        click_button 'Save'
      end

      it 'creates a new waiver record in the database with the provided data' do
        w = InternalPublicationWaiver.find_by(reason_for_waiver: 'no good reason')

        expect(w.authorship).to eq auth
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.new_path(model_name: :internal_publication_waiver)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
