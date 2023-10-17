# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'Admin troubleshooting dashboard', type: :feature do
  let!(:aif1) { create(:activity_insight_oa_file, publication: pub1, created_at: Time.new(2020, 1, 1, 0, 0, 0)) }
  let!(:aif2) { create(:activity_insight_oa_file, publication: pub2, created_at: Time.new(2023, 1, 1, 0, 0, 0)) }
  let!(:aif3) { create(:activity_insight_oa_file, publication: pub3, created_at: Time.new(2010, 1, 1, 0, 0, 0)) }
  let!(:pub1) { create(:publication, title: 'Title 1') }
  let!(:pub2) { create(:publication, title: 'Title 2') }
  let!(:pub3) { create(:publication, title: 'Title 3') }

  before do
    authenticate_admin_user
    visit activity_insight_oa_workflow_all_workflow_publications_path
  end

  describe 'listing all publications currently in workflow' do
    it 'show a table with header and the proper data for the publications in the table' do
      expect(page).to have_text('Author')
      expect(page).to have_text(pub1.activity_insight_upload_user.webaccess_id)
      expect(page).to have_text('Title')
      expect(page).to have_link(pub1.title)
      expect(page).to have_text('File Created At')
      expect(page).to have_text('Edit file in admin dashboard')
      expect(page).to have_css('tr').exactly(4).times
      expect(page).to have_link(aif1.download_filename)
    end

    it 'orders the publications by file creation date' do
      within(:xpath, '//table/tbody/tr[1]/td[2]') do
        expect(page).to have_content('Title 3')
      end
      within(:xpath, '//table/tbody/tr[2]/td[2]') do
        expect(page).to have_content('Title 1')
      end
      within(:xpath, '//table/tbody/tr[3]/td[2]') do
        expect(page).to have_content('Title 2')
      end
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
