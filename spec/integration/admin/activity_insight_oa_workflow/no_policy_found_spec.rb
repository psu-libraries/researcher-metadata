# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'Admin No Policy Found dashboard', type: :feature do
  let!(:aif1) { create(:activity_insight_oa_file, publication: pub1, user: user, created_at: Time.now - 1.year) }
  let!(:aif2) { create(:activity_insight_oa_file, publication: pub2, user: user, created_at: Time.now - 1.year) }
  let!(:pub1) {
    create(
      :publication,
      title: 'Pub1',
      permissions_last_checked_at: Time.now,
      preferred_version: 'noPolicyFound',
      doi: 'https://doi.org/10.123/def123',
      preferred_version_updated_at: Time.now - 1.month
    )
  }
  let!(:pub2) {
    create(
      :publication,
      title: 'Pub2',
      permissions_last_checked_at: Time.now,
      preferred_version: nil,
      doi: 'https://doi.org/10.123/def123'
    )
  }
  let!(:user) { create(:user, :with_psu_identity, webaccess_id: 'xyz123') }
  let!(:admin_user) { create(:user, is_admin: true, webaccess_id: 'abc123') }
  let(:uploader) { double 'uploader', file: file }
  let(:file) { double 'file', file: path }
  let(:path) { 'the/file/path' }

  before do
    authenticate_as(admin_user)
    allow(ActivityInsightFileUploader).to receive(:new).and_return uploader
    allow_any_instance_of(PsuIdentity::SearchService::Client).to receive(:userid).with(user.webaccess_id)
    visit activity_insight_oa_workflow_no_policy_found_path
  end

  describe 'listing publications that have no policy found' do
    it 'show a table with header and the proper data for the publications and files in the table', :js do
      expect(page).to have_text('Author')
      expect(page).to have_text('Title')
      expect(page).to have_text('Preferred Version Set On')
      expect(page).to have_text('Preferred Version Set By')
      expect(page).to have_text('File Created On')
      expect(page).to have_text('xyz123')
      expect(page).to have_text(pub1.title)
      expect(page).to have_text(pub1.created_at.strftime('%m/%d/%Y'))
      expect(page).to have_no_text(pub2.title)

      visit rails_admin.edit_path(model_name: :publication, id: pub2.id)

      find('#publication_preferred_version_field [title="Show All Items"]').click
      find('.ui-autocomplete .ui-menu-item', exact_text: 'No Policy Found').click
      click_on 'Save'
      visit activity_insight_oa_workflow_no_policy_found_path
      expect(page).to have_text(pub2.title)
      expect(page).to have_text(pub2.created_at.strftime('%m/%d/%Y'))
      expect(page).to have_text('abc123')
      expect(page).to have_text(Time.now.strftime('%m/%d/%Y'))
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
      click_link(pub1.title, match: :first)
      expect(page).to have_current_path rails_admin.edit_path(model_name: :publication, id: pub1.id)
    end
  end
end
