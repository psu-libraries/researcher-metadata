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
      license: 'https://creativecommons.org/licenses/by/4.0/',
      checked_for_set_statement: true,
      embargo_date: Date.today,
      downloaded: true,
      file_download_location: fixture_file_open('test_file.pdf')
    )
  }
  let!(:aif5) { create(:activity_insight_oa_file, publication: pub5, version: 'publishedVersion') }
  let!(:aif6) { create(:activity_insight_oa_file, publication: pub6, version: 'publishedVersion', wrong_version_emails_sent: 1) }
  let!(:pub1) { create(:publication, doi_verified: false) }
  let!(:pub2) { create(:publication, preferred_version: 'acceptedVersion') }
  let!(:pub3) { create(:publication, permissions_last_checked_at: Time.now) }
  let!(:pub4) { create(:publication, preferred_version: 'acceptedVersion')
  }
  let!(:pub5) { create(:publication, preferred_version: 'acceptedVersion') }
  let!(:pub6) { create(:publication, preferred_version: 'acceptedVersion') }

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

    describe 'clicking the link to the Unknown File Version Review page' do
      it 'redirects to the Unknown File Version Review page' do
        click_on 'Review Unknown File Versions'
        expect(page).to have_current_path activity_insight_oa_workflow_file_version_review_path
      end
    end

    describe 'clicking the link to the Wrong File Version Review page' do
      it 'redirects to the Wrong File Version Review page' do
        click_on 'Review Wrong File Versions'
        expect(page).to have_current_path activity_insight_oa_workflow_wrong_file_version_review_path
      end
    end

    describe 'clicking the link to the Wrong Version - Author Notified page' do
      it 'redirects to the Wrong Version - Author Notified page' do
        click_on 'Wrong Version - Author Notified'
        expect(page).to have_current_path activity_insight_oa_workflow_wrong_version_author_notified_review_path
      end
    end

    describe 'clicking the link to the Preferred Version Review page' do
      it 'redirects to the Preferred Version Review page' do
        click_on 'Review Preferred Version'
        expect(page).to have_current_path activity_insight_oa_workflow_preferred_version_review_path
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
