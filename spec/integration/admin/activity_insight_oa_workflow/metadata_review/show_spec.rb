# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'Admin Metadata Review publication detail', type: :feature do
  let!(:pub1) { create(:publication, title: 'Pub1', preferred_version: 'acceptedVersion') }
  let!(:pub2) {
    create(
      :sample_publication,
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
      it 'rescues the ActiveRecord::RecordNotFound error and returns to metadata review list with a flash message' do
        visit activity_insight_oa_workflow_review_publication_metadata_path(pub1)
        expect(page).to have_current_path activity_insight_oa_workflow_metadata_review_path
        expect(page).to have_content 'his publication is not ready for metadata review.'
      end
    end

    context 'viewing the details for a publication that is ready for metadata review' do
      before { visit activity_insight_oa_workflow_review_publication_metadata_path(pub2) }

      it 'shows the correct publication metadata and a link to edit the metadata' do
        expect(page).to have_content pub2.title
        expect(page).to have_content pub2.secondary_title
        expect(page).to have_content pub2.doi
        expect(page).to have_content pub2.published_on
        expect(page).to have_content pub2.preferred_journal_title
        expect(page).to have_content pub2.ai_file_for_deposit.license
        expect(page).to have_content pub2.ai_file_for_deposit.embargo_date
        expect(page).to have_content pub2.ai_file_for_deposit.set_statement
        pub2.contributor_names.each do |name|
          expect(page).to have_content name.name
        end
        expect(page).to have_content pub2.ai_file_for_deposit.user.webaccess_id
        expect(page).to have_content pub2.ai_file_for_deposit.user.name
        expect(page).to have_link pub2.ai_file_for_deposit.download_filename,
                                  href: activity_insight_oa_workflow_file_download_path(pub2.ai_file_for_deposit.id)
        expect(page).to have_content pub2.ai_file_for_deposit.created_at.to_date
        expect(page).to have_link 'Edit', href: rails_admin.edit_path(model_name: :publication, id: pub2.id)
        expect(page).to have_link 'Back', href: activity_insight_oa_workflow_metadata_review_path
      end

      context 'when the metadata is incomplete' do
        before do
          pub2.update abstract: nil
          visit activity_insight_oa_workflow_review_publication_metadata_path(pub2)
        end

        it 'does not have a button to deposit to scholarsphere and indicates the metadata is incomplete' do
          expect(page).to have_content 'Insufficient metadata to upload to ScholarSphere'
          expect(page).not_to have_button 'Deposit to ScholarSphere'
        end
      end

      context 'when the file download location is not present' do
        before do
          pub2.ai_file_for_deposit.file_download_location.remove!
          visit activity_insight_oa_workflow_review_publication_metadata_path(pub2)
        end

        it 'does not have a button to deposit to scholarsphere and indicates the metadata is incomplete' do
          expect(page).to have_content 'Insufficient metadata to upload to ScholarSphere'
          expect(page).to have_content 'Not Found'
          expect(page).not_to have_button 'Deposit to ScholarSphere'
        end
      end

      context 'when the publication has a pending scholarsphere deposit' do
        before do
          auth = create(:authorship, publication: pub2)
          create(:scholarsphere_work_deposit, authorship: auth, status: 'Pending')
          visit activity_insight_oa_workflow_review_publication_metadata_path(pub2)
        end

        it 'does not have a button to deposit to scholarsphere and indicates the deposit is pending' do
          expect(page).to have_content 'ScholarSphere upload pending...'
          expect(page).not_to have_button 'Deposit to ScholarSphere'
        end
      end

      context 'when the publication has a failed scholarsphere deposit' do
        before do
          auth = create(:authorship, publication: pub2)
          create(:scholarsphere_work_deposit, authorship: auth, status: 'Failed')
          visit activity_insight_oa_workflow_review_publication_metadata_path(pub2)
        end

        it 'does not have a button to deposit to scholarsphere and indicates the deposit is failed' do
          expect(page).to have_content 'ScholarSphere upload failed'
          expect(page).not_to have_button 'Deposit to ScholarSphere'
        end
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
