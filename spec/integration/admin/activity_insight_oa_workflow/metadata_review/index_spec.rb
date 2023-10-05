# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'Admin Metadata Review dashboard', type: :feature do
  let!(:aif1) {
    create(
      :activity_insight_oa_file,
      publication: pub1,
      version: 'publishedVersion',
      license: 'https://creativecommons.org/licenses/by/4.0/',
      checked_for_set_statement: true,
      checked_for_embargo_date: true,
      downloaded: true,
      file_download_location: fixture_file_open('test_file.pdf')
    )
  }
  let!(:aif2) {
    create(
      :activity_insight_oa_file,
      publication: pub2,
      version: 'acceptedVersion',
      license: 'https://creativecommons.org/licenses/by/4.0/',
      checked_for_set_statement: true,
      checked_for_embargo_date: true,
      downloaded: true,
      file_download_location: fixture_file_open('test_file.pdf'),
      created_at: 6.months.ago
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
  let!(:aif4) {
    create(
      :activity_insight_oa_file,
      publication: pub4,
      version: 'acceptedVersion',
      license: 'https://creativecommons.org/licenses/by/4.0/',
      checked_for_set_statement: true,
      checked_for_embargo_date: true,
      downloaded: true,
      file_download_location: fixture_file_open('test_file.pdf'),
      created_at: 8.months.ago
    )
  }
  let!(:aif5) {
    create(
      :activity_insight_oa_file,
      publication: pub4,
      version: 'publishedVersion',
      license: 'https://creativecommons.org/licenses/by/4.0/',
      checked_for_set_statement: true,
      checked_for_embargo_date: true,
      downloaded: true,
      file_download_location: fixture_file_open('test_file.pdf')
    )
  }
  let!(:pub1) { create(:publication, title: 'Pub1', preferred_version: 'acceptedVersion') }
  let!(:pub2) {
    create(
      :publication,
      title: 'Pub2',
      preferred_version: 'acceptedVersion'
    )
  }
  let!(:pub3) { create(:publication, title: 'Pub3', preferred_version: nil) }
  let!(:pub4) {
    create(
      :publication,
      title: 'Pub4',
      preferred_version: Publication::PUBLISHED_OR_ACCEPTED_VERSION
    )
  }

  context 'when the user is signed in as an admin' do
    before { authenticate_admin_user }

    describe 'listing publications that are ready for final metadata review prior to ScholarSphere deposit' do
      before { visit activity_insight_oa_workflow_metadata_review_path }

      it 'show a table with header and the proper data sorted oldest to newest for the publications in the table' do
        expect(page).to have_content('Title')
        expect(page).to have_content('Uploaded by')
        expect(page).to have_content('Uploaded on')

        rows = find_all('tr')
        expect(rows.count).to eq 3
        expect(rows[1]).to have_content('Pub2')

        expect(page).to have_link('Pub2'), href: activity_insight_oa_workflow_review_publication_metadata_path(pub2)
        expect(page).to have_content(aif2.user.webaccess_id)
        expect(page).to have_content(aif2.created_at.to_date)

        expect(page).to have_link('Pub4'), href: activity_insight_oa_workflow_review_publication_metadata_path(pub4)
        expect(page).to have_content(aif5.user.webaccess_id)
        expect(page).to have_content(aif5.created_at.to_date)

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
