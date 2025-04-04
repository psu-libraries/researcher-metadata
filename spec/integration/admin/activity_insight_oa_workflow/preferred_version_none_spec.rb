# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'Admin Preferred File Version None Review dashboard', type: :feature do
  let!(:aif1) { create(:activity_insight_oa_file, publication: pub1, version: 'publishedVersion', user: user) }
  let!(:aif2) { create(:activity_insight_oa_file, publication: pub2, version: 'publishedVersion', user: user) }
  let!(:pub1) { create(:publication, preferred_version: 'None', title: 'Title 1') }
  let!(:pub2) { create(:publication, preferred_version: 'None', title: 'Title 2') }
  let!(:user) { create(:user, :with_psu_identity, webaccess_id: 'abc123') }
  let(:uploader) { double 'uploader', file: file }
  let(:file) { double 'file', file: path }
  let(:path) { 'the/file/path' }

  before do
    authenticate_admin_user
    allow(ActivityInsightFileUploader).to receive(:new).and_return uploader
    allow_any_instance_of(PsuIdentity::SearchService::Client).to receive(:userid).with(user.webaccess_id)
    visit activity_insight_oa_workflow_preferred_file_version_none_review_path
  end

  describe 'listing publications that have a preferred version of none' do
    it 'show a table with header and the proper data for the publications and files in the table' do
      expect(page).to have_text('Author')
      expect(page).to have_text('Author Batch Email')
      expect(page).to have_text('Publication Email')
      expect(page).to have_text('Title')
      expect(page).to have_text('File Version')
      expect(page).to have_text('Download File')
      expect(page).to have_text(pub1.title)
      expect(page).to have_text(pub2.title)
      expect(page).to have_text('Final Published Version').twice
      expect(page).to have_link(aif1.download_filename)
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
      click_link(pub1.title, match: :first)
      expect(page).to have_current_path rails_admin.edit_path(model_name: :publication, id: pub1.id)
    end
  end

  describe 'clicking the button to send a batch email notification' do
    before { allow(AiOAStatusExportJob).to receive(:perform_later) }

    it 'sends an email, calls the status export job, and displays a confirmation message' do
      click_button('Send Batch Email', match: :first)
      expect(page).to have_current_path activity_insight_oa_workflow_preferred_file_version_none_review_path
      expect(page).to have_content('Email sent to abc123')
      open_email('abc123@psu.edu')
      expect(current_email).not_to be_nil
      expect(current_email.body).to match(/Title 1/)
      expect(current_email.body).to match(/Title 2/)
      expect(pub1.reload.preferred_file_version_none_email_sent).not_to be_nil
      expect(pub2.reload.preferred_file_version_none_email_sent).not_to be_nil
      expect(AiOAStatusExportJob).to have_received(:perform_later).with(aif1.id, 'Cannot Deposit')
    end
  end

  describe 'clicking the button to send a single email notification' do
    before { allow(AiOAStatusExportJob).to receive(:perform_later) }

    it 'sends an email and displays a confirmation message' do
      click_button('Send Email', match: :first)
      expect(page).to have_current_path activity_insight_oa_workflow_preferred_file_version_none_review_path
      expect(page).to have_content('Email sent to abc123')
      open_email('abc123@psu.edu')
      expect(current_email).not_to be_nil
      expect(pub1.reload.preferred_file_version_none_email_sent).not_to be_nil
      expect(pub2.reload.preferred_file_version_none_email_sent).to be_nil
      expect(AiOAStatusExportJob).to have_received(:perform_later).with(aif1.id, 'Cannot Deposit')
    end
  end
end
