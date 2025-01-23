# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'Admin Wrong File Version Author Notified Review dashboard', type: :feature do
  let!(:aif1) { create(:activity_insight_oa_file, publication: pub1, version: 'publishedVersion', user: user, wrong_version_emails_sent: 1, created_at: DateTime.now - 1.year) }
  let!(:aif2) { create(:activity_insight_oa_file, publication: pub2, version: 'publishedVersion', user: user, wrong_version_emails_sent: 3) }
  let!(:aif3) { create(:activity_insight_oa_file, publication: pub3, version: 'publishedVersion', user: user, wrong_version_emails_sent: nil) }
  let!(:pub1) { create(:publication, preferred_version: 'acceptedVersion', title: 'Title 1', wrong_oa_version_notification_sent_at: DateTime.now) }
  let!(:pub2) { create(:publication, preferred_version: 'acceptedVersion', title: 'Title 2') }
  let!(:pub3) { create(:publication, preferred_version: 'acceptedVersion', title: 'Title 3') }
  let!(:user) { create(:user, webaccess_id: 'abc123') }
  let(:uploader) { double 'uploader', file: file }
  let(:file) { double 'file', file: path }
  let(:path) { 'the/file/path' }

  before do
    authenticate_admin_user
    allow(ActivityInsightFileUploader).to receive(:new).and_return uploader
    allow_any_instance_of(PsuIdentity::SearchService::Client).to receive(:userid).with(user.webaccess_id)
    visit activity_insight_oa_workflow_wrong_version_author_notified_review_path
  end

  describe 'listing publications that need their file versions reviewed' do
    it 'show a table with header and the proper data for the publications and files in the table' do
      expect(page).to have_text('Author')
      expect(page).to have_text('Author Batch Email')
      expect(page).to have_text('Publication Email')
      expect(page).to have_text('Email Last Sent On')
      expect(page).to have_text('Title')
      expect(page).to have_text('Preferred Version')
      expect(page).to have_text('File Version')
      expect(page).to have_text('Notification Emails Sent')
      expect(page).to have_text('Download File')
      expect(page).to have_text(pub1.title)
      expect(page).to have_text(pub1.wrong_oa_version_notification_sent_at.strftime("%m/%d/%Y"))
      expect(page).not_to have_text(aif1.created_at.strftime("%m/%d/%Y"))
      expect(page).to have_text(pub2.title)
      expect(page).not_to have_text(pub3.title)
      expect(page).to have_text('Accepted Manuscript').twice
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
    it 'sends an email and displays a confirmation message' do
      click_button('Send Batch Email', match: :first)
      expect(page).to have_current_path activity_insight_oa_workflow_wrong_version_author_notified_review_path
      expect(page).to have_content('Email sent to abc123')
      open_email('abc123@psu.edu')
      expect(current_email).not_to be_nil
      expect(current_email.body).to match(/Version we have/)
      expect(current_email.body).to match(/Version that can be deposited/)
      expect(current_email.body).to match(/Title 1/)
      expect(current_email.body).to match(/Title 2/)
      expect(current_email.body).not_to match(/Title 3/)
      expect(pub1.reload.wrong_oa_version_notification_sent_at).not_to be_nil
      expect(pub2.reload.wrong_oa_version_notification_sent_at).not_to be_nil
      expect(pub3.reload.wrong_oa_version_notification_sent_at).to be_nil
      expect(aif1.reload.wrong_version_emails_sent).to eq(2)
      expect(aif2.reload.wrong_version_emails_sent).to eq(4)
      expect(aif3.reload.wrong_version_emails_sent).to be_nil
    end
  end

  describe 'clicking the button to send a single email notification' do
    it 'sends an email and displays a confirmation message' do
      click_button('Send Email', match: :first)
      expect(page).to have_current_path activity_insight_oa_workflow_wrong_version_author_notified_review_path
      expect(page).to have_content('Email sent to abc123')
      open_email('abc123@psu.edu')
      expect(current_email).not_to be_nil
      expect(current_email.body).to match(/Version we have/)
      expect(current_email.body).to match(/Version that can be deposited/)
      expect(current_email.body).to match(/Title 1/)
      expect(current_email.body).not_to match(/Title 2/)
      expect(current_email.body).not_to match(/Title 3/)
      expect(pub1.reload.wrong_oa_version_notification_sent_at).not_to be_nil
      expect(aif1.reload.wrong_version_emails_sent).to eq(2)
      expect(pub2.reload.wrong_oa_version_notification_sent_at).to be_nil
      expect(aif2.reload.wrong_version_emails_sent).to eq(3)
      expect(pub3.reload.wrong_oa_version_notification_sent_at).to be_nil
      expect(aif3.reload.wrong_version_emails_sent).to be_nil
    end
  end
end
