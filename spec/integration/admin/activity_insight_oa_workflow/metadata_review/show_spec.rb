# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'Admin Metadata Review publication detail', type: :feature do
  let!(:pub1) { create(:publication, title: 'Pub1', preferred_version: 'acceptedVersion') }
  let!(:pub2) {
    create(
      :publication,
      title: 'Pub2 Title',
      preferred_version: 'acceptedVersion'
    )
  }
  let!(:aif2) {
    create(
      :activity_insight_oa_file,
      publication: pub2,
      version: 'acceptedVersion',
      license: 'https://creativecommons.org/licenses/by/4.0/',
      set_statement: 'statement',
      embargo_date: Date.today,
      downloaded: true,
      file_download_location: fixture_file_open('test_file.pdf')
    )
  }

  context 'when the user is signed in as an admin' do
    before { authenticate_admin_user }

    context 'trying to view the details for a publication that is not ready for metadata review' do
      it 'responds with a 404' do
        expect { visit activity_insight_oa_workflow_review_publication_metadata_path(pub1) }
          .to raise_error ActiveRecord::RecordNotFound
      end
    end

    context 'viewing the details for a publication that is ready for metadata review' do
      before { visit activity_insight_oa_workflow_review_publication_metadata_path(pub2) }

      it 'shows the correct publication metadata and a link to edit the metadata' do
        expect(page).to have_content 'Pub2 Title'
        expect(page).to have_link 'Edit', href: rails_admin.edit_path(model_name: :publication, id: pub2.id)
        expect(page).to have_link 'Back', href: activity_insight_oa_workflow_metadata_review_path
      end
    end
  end

  context 'when the user is signed in as a non-admin' do
    before { authenticate_user }

    context 'trying to view the details for a publication that is ready for metadata review' do
      before { visit activity_insight_oa_workflow_review_publication_metadata_path(pub2) }

      it 'does not allow the user to visit the page' do
        expect(page).to have_current_path root_path
        expect(page).to have_content I18n.t('admin.authorization.not_authorized')
      end
    end
  end

  context 'when the user is not signed in' do
    context 'trying to view the details for a publication that is ready for metadata review' do
      before { visit activity_insight_oa_workflow_review_publication_metadata_path(pub2) }

      it 'does not allow the user to visit the page' do
        expect(page).to have_current_path root_path
        expect(page).to have_content I18n.t('devise.failure.unauthenticated')
      end
    end
  end
end
