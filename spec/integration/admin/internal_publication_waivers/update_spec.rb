# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'updating an internal publication waiver via the admin interface', type: :feature do
  let!(:waiver) { create(:internal_publication_waiver,
                         authorship: authorship,
                         reason_for_waiver: 'because') }
  let!(:authorship) { create(:authorship, user: user, publication: pub) }
  let!(:user) { create(:user, first_name: 'James', last_name: 'Testington') }
  let!(:other_user) { create(:user, first_name: 'Other', last_name: 'User') }
  let!(:pub) { create(:publication, title: 'A Test Publication') }
  let!(:other_pub) { create(:publication, title: 'Other Pub') }

  context 'when the current user is an admin', js: true do
    before do
      authenticate_admin_user
      visit rails_admin.edit_path(model_name: :internal_publication_waiver, id: waiver.id)
    end

    describe 'using the edit page' do
      it 'has link to edit and new modal forms for user associated with the waiver and dropdown of users' do
        click_link 'Edit this User'
        sleep 1
        expect(page).to have_content "Edit User 'James Testington'"
        fill_in 'Middle name', with: 'Josh'
        click_link 'Save'
        click_button 'Save and edit'
        expect(page).to have_content 'James Josh Testington'
        expect(page).not_to have_content 'Other User'
        find_all('label[title="Show All Items"]').first.click
        expect(page).to have_content 'Other User'
        click_link 'Add a new User'
        expect(page).to have_content "New User"
      end

      it 'has link to edit and new modal forms for the publication associated with the waiver and dropdown of publications' do
        click_link 'Edit this Publication'
        sleep 0.5
        expect(page).to have_content "Edit Publication 'A Test Publication'"
        
      end
    end

    describe 'submitting the form with new data to update the waiver record' do
      before do
        fill_in 'Reason for waiver', with: 'new reason'
        click_button 'Save'
      end

      it "updates the waiver record's reason" do
        expect(waiver.reload.reason_for_waiver).to eq 'new reason'
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.edit_path(model_name: :internal_publication_waiver, id: waiver.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
