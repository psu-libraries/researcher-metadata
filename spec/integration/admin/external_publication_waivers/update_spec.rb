# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'updating an external publication waiver via the admin interface', type: :feature do
  let!(:waiver) { create(:external_publication_waiver,
                         user: user,
                         publication_title: 'Test Pub',
                         reason_for_waiver: 'because',
                         abstract: 'summary of pub',
                         doi: 'abc-123',
                         journal_title: 'Science Journal',
                         publisher: 'A Publisher') }
  let!(:user) { create(:user, first_name: 'Emily', last_name: 'Tester') }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.edit_path(model_name: :external_publication_waiver, id: waiver.id)
    end

    describe 'viewing the edit page' do
      it 'shows a link to the user who requested the waiver' do
        expect(page).to have_link 'Emily Tester', href: rails_admin.show_path(model_name: :user, id: user.id)
      end
    end

    describe 'submitting the form with new data to update the waiver record' do
      before do
        fill_in 'Publication title', with: 'New Pub'
        fill_in 'Reason for waiver', with: 'new reason'
        fill_in 'Abstract', with: 'new abstract'
        fill_in 'DOI', with: 'new-doi'
        fill_in 'Journal title', with: 'New Journal'
        fill_in 'Publisher', with: 'New Publisher'
        click_button 'Save'
      end

      it "updates the waiver record's publication title" do
        expect(waiver.reload.publication_title).to eq 'New Pub'
      end

      it "updates the waiver record's reason" do
        expect(waiver.reload.reason_for_waiver).to eq 'new reason'
      end

      it "updates the waiver record's abstract" do
        expect(waiver.reload.abstract).to eq 'new abstract'
      end

      it "updates the waiver record's DOI" do
        expect(waiver.reload.doi).to eq 'new-doi'
      end

      it "updates the waiver record's journal title" do
        expect(waiver.reload.journal_title).to eq 'New Journal'
      end

      it "updates the waiver record's publisher" do
        expect(waiver.reload.publisher).to eq 'New Publisher'
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.edit_path(model_name: :external_publication_waiver, id: waiver.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
