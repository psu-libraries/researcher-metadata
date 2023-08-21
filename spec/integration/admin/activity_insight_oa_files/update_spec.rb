# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'updating a activity insight oa file via the admin interface', type: :feature do
  let!(:aif) { create(:activity_insight_oa_file) }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.edit_path(model_name: :activity_insight_oa_file, id: aif.id)
    end

    describe 'viewing the form' do
      it 'does not allow the location to be set' do
        expect(page).not_to have_field 'Location'
        expect(page).to have_content aif.location
      end

      it 'shows a form for version' do
        expect(page).to have_field 'Version'
      end
    end

    describe 'submitting the form with new data to update a publication record' do
      before do
        select 'unknown', from: 'Version'
        click_on 'Save'
      end

      it "updates the activity insight oa file's data" do
        expect(aif.reload.version).to eq 'unknown'
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.edit_path(model_name: :activity_insight_oa_file, id: aif.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
