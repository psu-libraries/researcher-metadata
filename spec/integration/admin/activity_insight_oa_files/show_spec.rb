# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin activity insight oa file detail page', type: :feature do
  let!(:pub) { create(:publication, title: "AIF's Publication's Title") }
  let!(:aif) do
    create(:activity_insight_oa_file,
           publication: pub,
           version: 'unknown')
  end

  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      before { visit rails_admin.show_path(model_name: :activity_insight_oa_file, id: aif.id) }

      it 'shows the activity insight oa file detail heading' do
        expect(page).to have_content "Details for Activity insight OA file 'ActivityInsightOAFile ##{aif.id}'"
      end

      it "shows the activity insight oa file's location" do
        expect(page).to have_content aif.location
      end

      it "shows the activity insight oa file's version" do
        expect(page).to have_content aif.version
      end

      it "shows the activity insight oa file's created_at timestamp" do
        expect(page).to have_content aif.created_at.strftime('%B %d, %Y')
      end

      it "shows the activity insight oa file's updated_at timestamp" do
        expect(page).to have_content aif.updated_at.strftime('%B %d, %Y')
      end

      it "has a link the activity insight oa file's publication" do
        expect(page).to have_link pub.title
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.show_path(model_name: :activity_insight_oa_file, id: aif.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
