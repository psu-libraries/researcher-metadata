# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'Admin Metadata Review dashboard', type: :feature do
  let!(:aif1) {
    create(
      :activity_insight_oa_file,
      publication: pub1,
      version: 'publishedVersion',
      downloaded: true,
      file_download_location: fixture_file_open('test_file.pdf')
    )
  }
  let!(:aif2) {
    create(
      :activity_insight_oa_file,
      publication: pub2,
      version: 'acceptedVersion',
      downloaded: true,
      file_download_location: fixture_file_open('test_file.pdf')
    )
  }
  let!(:aif3) {
    create(
      :activity_insight_oa_file,
      publication: pub3,
      version: nil,
      downloaded: true,
      file_download_location: fixture_file_open('test_file.pdf')
    )
  }
  let!(:pub1) { create(:publication, title: 'Pub1', preferred_version: 'acceptedVersion') }
  let!(:pub2) {
    create(
      :publication,
      title: 'Pub2',
      preferred_version: 'acceptedVersion',
      licence: 'license',
      set_statement: 'statement',
      embargo_date: Date.current
    )
  }
  let!(:pub3) { create(:publication, title: 'Pub3', preferred_version: nil) }

  context 'when the user is signed in as an admin' do
    before { authenticate_admin_user }

    describe 'listing publications that are ready for final metadata review prior to ScholarSphere deposit' do
      before { visit activity_insight_oa_workflow_metadata_review_path }

      it 'show a table with header and the proper data for the publications in the table' do
        expect(page).to have_link('Pub2'), href: activity_insight_oa_workflow_review_publication_metadata_path(pub2)

        expect(page).not_to have_text('Pub1')
        expect(page).not_to have_text('Pub3')

        expect(page).to have_link 'Back', href: activity_insight_oa_workflow_path
      end
    end
  end

  context 'when the user is signed in as a non-admin' do
    before { authenticate_user }

    context 'trying to view the details for a publication that is ready for metadata review' do
      before { visit activity_insight_oa_workflow_metadata_review_path }

      it 'does not allow the user to visit the page' do
        expect(page).to have_current_path root_path
        expect(page).to have_content I18n.t('admin.authorization.not_authorized')
      end
    end
  end

  context 'when the user is not signed in' do
    context 'trying to view the details for a publication that is ready for metadata review' do
      before { visit activity_insight_oa_workflow_metadata_review_path }

      it 'does not allow the user to visit the page' do
        expect(page).to have_current_path root_path
        expect(page).to have_content I18n.t('devise.failure.unauthenticated')
      end
    end
  end
end
