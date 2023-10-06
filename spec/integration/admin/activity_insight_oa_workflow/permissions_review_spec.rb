# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'Admin Open Access Permissions Review dashboard', type: :feature do
  let!(:aif1) {
    create(
      :activity_insight_oa_file,
      publication: pub1,
      permissions_last_checked_at: Time.now,
      version: 'acceptedVersion',
      license: 'https://creativecommons.org/licenses/by/4.0/',
      checked_for_set_statement: true,
      embargo_date: Date.today
    )
  }
  let!(:aif2a) {
    create(
      :activity_insight_oa_file,
      publication: pub2,
      permissions_last_checked_at: Time.now,
      version: 'acceptedVersion',
      license: nil,
      checked_for_set_statement: true,
      embargo_date: Date.today
    )
  }
  let!(:aif2b) {
    create(
      :activity_insight_oa_file,
      publication: pub2,
      permissions_last_checked_at: Time.now,
      version: 'publishedVersion',
      license: nil,
      checked_for_set_statement: true,
      embargo_date: Date.today
    )
  }
  let!(:aif3) {
    create(
      :activity_insight_oa_file,
      publication: pub3,
      version: 'acceptedVersion'
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
    visit activity_insight_oa_workflow_permissions_review_path
  end

  describe 'listing publications that have files that need permissions metadata review prior to deposit' do
    it 'show a table with header and the proper data for the publications in the table' do
      within 'thead' do
        expect(page).to have_text('Title')
        expect(page).to have_text('File metadata: Filename (Version')
      end

      within "#publication_#{pub2.id}" do
        expect(page).to have_link('Pub2', href: "#{rails_admin.edit_path(model_name: :publication, id: pub2.id)}#publication_preferred_version")
        expect(page).to have_link(aif2a.download_filename, href: rails_admin.edit_path(model_name: :activity_insight_oa_file, id: aif2a.id))
        expect(page).not_to have_text aif2b.download_filename
      end

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
