# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin user organization membership detail page', type: :feature do
  let(:user) { create(:user, first_name: 'Bob', last_name: 'Testuser') }
  let(:org) { create :organization, name: 'Test Org' }
  let!(:membership) { create :user_organization_membership,
                             user: user,
                             organization: org,
                             import_source: 'Pure',
                             source_identifier: 'pure-abc123',
                             position_title: 'test position',
                             started_on: Date.new(2000, 1, 1),
                             ended_on: Date.new(2010, 2, 2),
                             updated_by_user_at: Time.zone.local(2018, 11, 1, 11, 26, 0) }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
    end

    describe 'the page content' do
      before { visit rails_admin.show_path(model_name: :user_organization_membership, id: membership.id) }

      it 'shows the membership detail heading' do
        expect(page).to have_content "Details for User organization membership 'Bob Testuser - Test Org'"
      end

      it 'shows the user' do
        expect(page).to have_link 'Bob Testuser'
      end

      it 'shows the organization' do
        expect(page).to have_link 'Test Org'
      end

      it "shows the membership's import source" do
        expect(page).to have_content 'Pure'
      end

      it "shows the membership's Pure identifier" do
        expect(page).to have_content 'pure-abc123'
      end

      it "shows the membership's position title" do
        expect(page).to have_content 'test position'
      end

      it 'shows the timestamp when the membership was last updated by a user' do
        expect(page).to have_content 'November 01, 2018 11:26'
      end

      it "shows the membership's start date" do
        expect(page).to have_content 'January 01, 2000'
      end

      it "shows the membership's end date" do
        expect(page).to have_content 'February 02, 2010'
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.show_path(model_name: :user_organization_membership, id: membership.id) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.show_path(model_name: :user_organization_membership, id: membership.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
