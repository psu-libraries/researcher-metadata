# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'Admin Permissions Review dashboard', type: :feature do
  let!(:aif1) { create(:activity_insight_oa_file, publication: pub1) }
  let!(:aif2) { create(:activity_insight_oa_file, publication: pub2) }
  let!(:aif4) { create(:activity_insight_oa_file, publication: pub4) }
  let!(:pub1) {
    create(
      :publication,
      title: 'Pub1',
      permissions_last_checked_at: Time.now,
      preferred_version: 'acceptedVersion'
    )
  }
  let!(:pub2) {
    create(
      :publication,
      permissions_last_checked_at: Time.now,
      licence: 'license',
      preferred_version: 'publishedVersion',
      checked_for_set_statement: true,
      checked_for_embargo_date: true
    )
  }
  let!(:pub3) { create(:publication, permissions_last_checked_at: Time.now) }
  let!(:pub4) {
    create(
      :publication,
      title: 'Pub4',
      permissions_last_checked_at: Time.now,
      licence: 'The license',
      preferred_version: nil,
      set_statement: 'The set statement.',
      embargo_date: Date.new(2023, 8, 17),
      checked_for_set_statement: true,
      checked_for_embargo_date: true
    )
  }

  before do
    authenticate_admin_user
    visit activity_insight_oa_workflow_permissions_review_path
  end

  describe 'listing publications that need their Permissions reviewed' do
    it 'show a table with header and the proper data for the publications in the table' do
      within 'thead' do
        expect(page).to have_text('Title')
        expect(page).to have_text('License')
        expect(page).to have_text('Preferred Version')
        expect(page).to have_text('Deposit Statement')
        expect(page).to have_text('Checked Deposit Statement')
        expect(page).to have_text('Embargo Date')
        expect(page).to have_text('Checked Embargo Date')
      end

      within "tr#publication_#{pub1.id}" do
        expect(page).to have_link('Pub1')
        within 'td#license' do
          expect(page).to have_text('Not Found')
        end

        within 'td#preferred-version' do
          expect(page).to have_text('Accepted Manuscript')
        end

        within 'td#set-statement' do
          expect(page).to have_text('Not Found')
        end

        within 'td#checked-set-statement' do
          expect(page).not_to have_text('✓')
        end

        within 'td#embargo-date' do
          expect(page).to have_text('Not Found')
        end

        within 'td#checked-embargo-date' do
          expect(page).not_to have_text('✓')
        end
      end

      within "tr#publication_#{pub4.id}" do
        expect(page).to have_link('Pub4')
        within 'td#license' do
          expect(page).to have_text('The license')
        end

        within 'td#preferred-version' do
          expect(page).to have_text('Not Found')
        end

        within 'td#set-statement' do
          expect(page).to have_text('The set statement.')
        end

        within 'td#checked-set-statement' do
          expect(page).to have_text('✓')
        end

        within 'td#embargo-date' do
          expect(page).to have_text('2023-08-17')
        end

        within 'td#checked-embargo-date' do
          expect(page).to have_text('✓')
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
