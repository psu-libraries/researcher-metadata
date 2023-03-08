# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'Admin File Version Review dashboard', type: :feature do
  let!(:aif1) { create(:activity_insight_oa_file, publication: pub1, version: 'unknown') }
  let!(:aif2) { create(:activity_insight_oa_file, publication: pub1, version: 'unknown') }
  let!(:aif3) { create(:activity_insight_oa_file, publication: pub2, version: 'publishedVersion') }
  let!(:aif4) { create(:activity_insight_oa_file, publication: pub2, version: 'unknown') }
  let!(:pub1) { create(:publication, preferred_version: 'acceptedVersion') }
  let!(:pub2) { create(:publication, preferred_version: 'acceptedVersion') }

  before do
    authenticate_admin_user
    visit activity_insight_oa_workflow_file_version_review_path
  end

  describe 'listing publications that need their file versions reviewed' do
    it 'show a table with header and the proper data for the publications and files in the table' do
      expect(page).to have_text('Title')
      expect(page).to have_text('Preferred Version')
      expect(page).to have_text('Files')
      expect(page).to have_text('Version Status')
      expect(page).to have_text(pub1.title)
      expect(page).to have_text(pub2.title)
      expect(find_all('td[rowspan="2"]').count).to eq 4
      expect(find_all('td[rowspan="2"]').first.text).to eq pub1.title
      expect(page).to have_text('Accepted Manuscript').twice
      expect(page).to have_text(pub1.activity_insight_oa_files.first.location)
      expect(page).to have_text(pub2.activity_insight_oa_files.first.location)
      expect(page).to have_text('Unknown Version')
      expect(page).to have_text('Wrong Version')
    end
  end

  describe 'clicking "<< Back"' do
    it 'redirects to the OA Workflow Dashboard' do
      click_link '<< Back'
      expect(page).to have_current_path activity_insight_oa_workflow_path
    end
  end

  describe 'clicking a link to edit a file' do
    it "redirects to that Activity Insight OA File's edit page" do
      click_link aif1.location
      expect(page).to have_current_path rails_admin.edit_path(model_name: :activity_insight_oa_file, id: aif1.id)
    end
  end
end
