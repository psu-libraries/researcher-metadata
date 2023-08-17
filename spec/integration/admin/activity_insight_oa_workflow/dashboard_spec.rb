# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'Admin Activity Insight OA Workflow dashboard', type: :feature do
  let!(:aif1) { create(:activity_insight_oa_file, publication: pub1) }
  let!(:aif2) { create(:activity_insight_oa_file, publication: pub2, version: 'unknown') }
  let!(:aif3) { create(:activity_insight_oa_file, publication: pub3) }
  let!(:aif4) {
    create(
      :activity_insight_oa_file,
      publication: pub4,
      version: 'acceptedVersion',
      downloaded: true,
      file_download_location: fixture_file_open('test_file.pdf')
    )
  }
  let!(:pub1) { create(:publication, doi_verified: false) }
  let!(:pub2) { create(:publication, preferred_version: 'acceptedVersion') }
  let!(:pub3) { create(:publication, permissions_last_checked_at: Time.now) }
  let!(:pub4) { create(:publication, preferred_version: 'acceptedVersion') }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit activity_insight_oa_workflow_path
    end

    describe 'accessing the page' do
      it 'loads the page' do
        expect(page).to have_current_path activity_insight_oa_workflow_path
        expect(page).to have_content 'Activity Insight Open Access Workflow'
      end
    end

    describe 'clicking the link to the DOI Verification page' do
      it 'redirects to the DOI Verification page' do
        click_on 'Verify DOIs'
        expect(page).to have_current_path activity_insight_oa_workflow_doi_verification_path
      end
    end

    describe 'clicking the link to the File Version Review page' do
      it 'redirects to the File Version Review page' do
        click_on 'Review File Versions'
        expect(page).to have_current_path activity_insight_oa_workflow_file_version_review_path
      end
    end

    describe 'clicking the link to the Permissions Review page' do
      it 'redirects to the Permissions Review page' do
        click_on 'Review Permissions'
        expect(page).to have_current_path activity_insight_oa_workflow_permissions_review_path
      end
    end

    describe 'clicking the link to the Metadata Review page' do
      it 'redirects to the Metadata Review page' do
        click_on 'Review Publication Metadata'
        expect(page).to have_current_path activity_insight_oa_workflow_metadata_review_path
      end
    end
  end

  context 'when the current user is not an admin' do
    before do
      authenticate_user
      visit activity_insight_oa_workflow_path
    end

    describe 'accessing the page' do
      it 'redirects to home page' do
        expect(page).to have_current_path root_path
      end
    end
  end
end
