# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'updating an open access location via the admin interface', type: :feature do
  let!(:oal) { create(:open_access_location,
                      source: Source::OPEN_ACCESS_BUTTON,
                      url: 'https://example.com/test') }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.edit_path(model_name: :open_access_location, id: oal.id)
    end

    describe 'viewing the edit page' do
      it 'shows the correct fields' do
        expect(page).to have_field 'URL'
        expect(page).to have_field 'Source'
      end

      it 'shows the correct options for the Source field', :js do
        find('.dropdown-toggle').click
        within '#ui-id-1' do
          expect(page).to have_content Source.new(Source::OPEN_ACCESS_BUTTON).display
          expect(page).to have_no_content Source.new(Source::USER).display
        end
      end
    end

    describe 'submitting the form with new data to update the open access location record' do
      before do
        fill_in 'URL', with: 'https://example.com/new'
        click_on 'Save'
      end

      it "updates the open access location record's URL" do
        expect(oal.reload.url).to eq 'https://example.com/new'
      end

      it "does not update the open access location record's source" do
        expect(oal.reload.source).to eq Source::OPEN_ACCESS_BUTTON
      end

      it 'redirects back to the detail view of the open access location' do
        expect(page).to have_current_path rails_admin.show_path(model_name: :open_access_location, id: oal.id), ignore_query: true
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.edit_path(model_name: :open_access_location, id: oal.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
