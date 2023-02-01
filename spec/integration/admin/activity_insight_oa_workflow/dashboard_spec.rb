# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'Admin Activity Insight Oa Workflow dashboard', type: :feature do
  let!(:aif) { create :activity_insight_oa_file, publication: pub }
  let!(:pub) { create :publication, doi_verified: false }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit activity_insight_oa_workflow_path
    end

    describe 'accessing the page' do
      it 'loads the page' do
        expect(page).to have_current_path activity_insight_oa_workflow_path
        expect(page).to have_content 'Activity Insight Open Access Workflow'
      end
    end

    describe 'clicking the link to the DOI Verification page' do
      it 'redirects to the DOI Verification page' do
        click_on class: 'card-link'
        expect(page).to have_current_path activity_insight_oa_workflow_doi_verification_path
      end
    end
  end

  context 'when the current user is not an admin' do
    before do
      authenticate_user
      visit activity_insight_oa_workflow_path
    end

    describe 'accessing the page' do
      it 'redirects to home page' do
        expect(page).to have_current_path root_path
      end
    end
  end
end
