# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin activity insight oa file list', type: :feature do
  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      let!(:pub1) { create(:publication, title: 'Test Publication') }
      let!(:pub2) { create(:publication, title: 'Another Publication') }
      let!(:aif1) do
        create(:activity_insight_oa_file, 
               publication: pub1,
               version: 'acceptedVersion')
      end
      let!(:aif2) do
        create(:activity_insight_oa_file, 
               publication: pub2,
               version: nil)
      end

      before { visit rails_admin.index_path(model_name: :activity_insight_oa_file) }

      it 'shows the activity insight oa file list heading' do
        expect(page).to have_content 'List of Activity insight OA files'
      end

      it 'shows information about each file' do
        expect(page).to have_link pub1.title
        expect(page).to have_content aif1.location
        expect(page).to have_content 'acceptedVersion'

        expect(page).to have_link pub2.title
        expect(page).to have_content aif2.location
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.index_path(model_name: :activity_insight_oa_file) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.index_path(model_name: :activity_insight_oa_file)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
