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
      license: 'https://creativecommons.org/licenses/by/4.0/',
      set_statement: 'statement',
      checked_for_embargo_date: true,
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
      preferred_version: 'acceptedVersion'
    )
  }
  let!(:pub3) { create(:publication, title: 'Pub3', preferred_version: nil) }

  before do
    authenticate_admin_user
    visit activity_insight_oa_workflow_metadata_review_path
  end

  describe 'listing publications that are ready for final metadata review prior to ScholarSphere deposit' do
    it 'show a table with header and the proper data for the publications in the table' do
      expect(page).to have_text('Pub2')

      expect(page).not_to have_text('Pub1')
      expect(page).not_to have_text('Pub3')
    end
  end

  describe 'clicking "<< Back"' do
    it 'redirects to the OA Workflow Dashboard' do
      click_link '<< Back'
      expect(page).to have_current_path activity_insight_oa_workflow_path
    end
  end

  describe 'clicking a link to edit a publication' do
    it "redirects to that publication's edit page" do
      click_link pub2.title
      expect(page).to have_current_path rails_admin.edit_path(model_name: :publication, id: pub2.id)
    end
  end
end
