# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'Admin Permissions Review dashboard', type: :feature do
  let!(:aif1) { create(:activity_insight_oa_file, publication: pub1) }
  let!(:aif2) { create(:activity_insight_oa_file, publication: pub2) }
  let!(:pub1) { create(:publication, permissions_last_checked_at: Time.now) }
  let!(:pub2) { create(:publication, permissions_last_checked_at: Time.now, licence: 'licence') }
  let!(:pub3) { create(:publication, permissions_last_checked_at: Time.now) }

  before do
    authenticate_admin_user
    visit activity_insight_oa_workflow_permissions_review_path
  end

  describe 'listing publications that need their Permissions reviewed' do
    it 'show a table with header and the proper data for the publications in the table' do
      expect(page).to have_text('Title')
      expect(page).to have_text('Licence')
      expect(page).to have_text('Preferred Version')
      expect(page).to have_link(pub1.title)
      expect(page).to have_text('Not Found')
      expect(page).to have_css('tr').exactly(2).times
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
      click_link pub1.title
      expect(page).to have_current_path rails_admin.edit_path(model_name: :publication, id: pub1.id)
    end
  end
end
