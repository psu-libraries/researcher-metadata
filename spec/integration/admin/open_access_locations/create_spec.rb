# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Creating an open access location', type: :feature do
  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.new_path(model_name: :open_access_location)
    end

    describe 'visiting the form to create a new open access location' do
      # The rails_admin `create` action is enabled for open access locations so
      # that admin users can add a location to a publication via nested attributes
      # on the publication record. The action that renders the form for creating a
      # new open access location directly is not intended to actually be used (there
      # are no links to it in the admin UI). In fact, the 'new' form isn't even
      # configured to show all of the required fields when rendered outside of the
      # context of a publication. So we can't actually submit the form that we're
      # testing here. The purpose of this test is just to verify that the `create`
      # action is enabled and that the form is configured with the correct fields for
      # the nested context.
      it_behaves_like 'a page with the admin layout'
      it 'shows the correct content' do
        expect(page).to have_content 'New Open access location'
      end

      it 'shows the correct fields' do
        expect(page).to have_field 'URL'
        expect(page).to have_field 'Source'
      end

      it 'shows the correct options for the Source field', js: true do
        find('.dropdown-toggle').click
        within '#ui-id-1' do
          expect(page).to have_content Source.new(Source::USER).display
          expect(page).to have_content Source.new(Source::SCHOLARSPHERE).display
          expect(page).not_to have_content Source.new(Source::OPEN_ACCESS_BUTTON).display
        end
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.new_path(model_name: :open_access_location)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
