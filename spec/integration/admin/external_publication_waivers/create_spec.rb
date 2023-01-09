# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Creating an external publication waiver', type: :feature do
  context 'when the current user is an admin' do
    let!(:user) { create(:user, first_name: 'Emily', last_name: 'Tester') }

    before do
      authenticate_admin_user
      visit rails_admin.new_path(model_name: :external_publication_waiver)
    end

    describe 'visiting the form to create a new waiver' do
      it_behaves_like 'a page with the admin layout'
      it 'show the correct content' do
        expect(page).to have_content 'New External publication waiver'
      end
    end

    describe 'submitting the form to create a new waiver' do
      before do
        select 'Emily Tester', from: 'User'
        fill_in 'Publication title', with: 'Test Pub'
        fill_in 'Reason for waiver', with: 'because'
        fill_in 'Abstract', with: 'summary of pub'
        fill_in 'DOI', with: 'abc-123'
        fill_in 'Journal title', with: 'Science Journal'
        fill_in 'Publisher', with: 'A Publisher'
        click_button 'Save'
      end

      it 'creates a new waiver record in the database with the provided data' do
        w = ExternalPublicationWaiver.find_by(publication_title: 'Test Pub')

        expect(w.user).to eq user
        expect(w.reason_for_waiver).to eq 'because'
        expect(w.abstract).to eq 'summary of pub'
        expect(w.doi).to eq 'abc-123'
        expect(w.journal_title).to eq 'Science Journal'
        expect(w.publisher).to eq 'A Publisher'
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.new_path(model_name: :external_publication_waiver)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
