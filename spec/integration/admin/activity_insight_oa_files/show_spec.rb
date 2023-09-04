# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin activity insight oa file detail page', type: :feature do
  let!(:pub) { create(:publication, title: "AIF's Publication's Title") }
  let!(:u) { create(:user) }
  let!(:aif) do
    create(:activity_insight_oa_file,
           user: u,
           publication: pub,
           version: 'unknown',
           downloaded: true,
           file_download_location: fixture_file_open('test_file.pdf'),
           license: 'https://rightsstatements.org/page/InC/1.0/',
           set_statement: 'publisher set statement',
           embargo_date: Date.new(2025, 8, 31))
  end

  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      before { visit rails_admin.show_path(model_name: :activity_insight_oa_file, id: aif.id) }

      it 'shows the correct data for the publication' do
        expect(page).to have_content "Details for Activity insight OA file 'ActivityInsightOAFile ##{aif.id}'"
        expect(page).to have_content aif.location
        expect(page).to have_content aif.version
        expect(page).to have_link 'Test User'
        expect(page).to have_content aif.created_at.strftime('%B %d, %Y')
        expect(page).to have_content aif.updated_at.strftime('%B %d, %Y')
        expect(page).to have_link pub.title
        expect(page).to have_link 'test_file.pdf'
        expect(page).to have_content '✓'
        expect(page).to have_content 'https://rightsstatements.org/page/InC/1.0/'
        expect(page).to have_content 'publisher set statement'
        expect(page).to have_content 'August 31, 2025'
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.show_path(model_name: :activity_insight_oa_file, id: aif.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
