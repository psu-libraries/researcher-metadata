# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'Admin Preferred Version Review dashboard', type: :feature do
  let!(:aif1) { create(:activity_insight_oa_file, publication: pub1) }
  let!(:aif2) { create(:activity_insight_oa_file, publication: pub2) }
  let!(:aif4a) { create(:activity_insight_oa_file, publication: pub4) }
  let!(:aif4b) { create(:activity_insight_oa_file, publication: pub4, version: 'acceptedVersion') }
  let!(:pub1) {
    create(
      :publication,
      title: 'Pub1',
      permissions_last_checked_at: Time.now
    )
  }
  let!(:pub2) {
    create(
      :publication,
      permissions_last_checked_at: Time.now,
      preferred_version: 'publishedVersion'
    )
  }
  let!(:pub3) { create(:publication, permissions_last_checked_at: Time.now) }
  let!(:pub4) {
    create(
      :publication,
      title: 'Pub4',
      permissions_last_checked_at: Time.now
    )
  }
  let(:uploader) { double 'uploader', file: file }
  let(:file) { double 'file', file: path }
  let(:path) { 'the/file/path' }

  before do
    authenticate_admin_user
    allow(ActivityInsightFileUploader).to receive(:new).and_return uploader
    visit activity_insight_oa_workflow_preferred_version_review_path
  end

  describe 'listing publications that need their preferred version reviewed' do
    it 'shows a table with header and the proper data for the publications in the table' do
      within 'thead' do
        expect(page).to have_text('Title')
        expect(page).to have_text('Files')
      end

      within "tr#publication_#{pub1.id}" do
        expect(page).to have_link('Pub1')

        within 'td.files' do
          expect(page).to have_link(
            "#{aif1.download_filename} (unknown)",
            href: rails_admin.edit_path(model_name: :activity_insight_oa_file, id: aif1.id)
          )
        end
      end

      within "tr#publication_#{pub4.id}" do
        expect(page).to have_link('Pub4')

        within 'td.files' do
          expect(page).to have_link(
            "#{aif4a.download_filename} (unknown)",
            href: rails_admin.edit_path(model_name: :activity_insight_oa_file, id: aif4a.id)
          )
          expect(page).to have_link(
            "#{aif4b.download_filename} (acceptedVersion)",
            href: rails_admin.edit_path(model_name: :activity_insight_oa_file, id: aif4b.id)
          )
        end
      end

      expect(page).to have_css('tr').exactly(3).times
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
      click_link 'Pub1'
      expect(page).to have_current_path rails_admin.edit_path(model_name: :publication, id: pub1.id)
    end
  end
end
