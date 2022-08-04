# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'updating a user via the admin interface', type: :feature do
  let!(:user) { create :user,
                       first_name: 'Bob',
                       middle_name: 'A.',
                       last_name: 'Testuser',
                       webaccess_id: 'bat123',
                       pure_uuid: 'pure-abc123',
                       activity_insight_identifier: 'ai-xyz789',
                       penn_state_identifier: '987654321',
                       is_admin: false,
                       show_all_publications: false,
                       show_all_contracts: false,
                       scopus_h_index: 649 }
  let!(:user_org) { create :organization,
                           owner: user,
                           name: "User's Organization" }

  context 'when the current user is an admin' do
    let!(:member_org) { create :organization, name: 'Test Org' }

    before do
      create :user_organization_membership, user: user, organization: member_org
      authenticate_admin_user
      visit rails_admin.edit_path(model_name: :user, id: user.id)
    end

    describe 'viewing the edit page' do
      it "shows the user's WebAccess ID" do
        expect(page).to have_content 'bat123'
      end

      it "does not allow the user's webaccess ID to be updated" do
        expect(page).not_to have_field 'Penn State WebAccess ID'
      end

      it "shows the user record's managed organizations" do
        expect(page).to have_content "User's Organization"
      end

      it "does not allow the user's database timestamps to be manually updated" do
        expect(page).not_to have_field 'Created at'
        expect(page).not_to have_field 'Updated at'
      end

      it "does not allow the user's manual update timestamp to be updated" do
        expect(page).not_to have_field 'Updated by user at'
      end
    end

    describe 'submitting the form with new data to update the user record' do
      before do
        fill_in 'First name', with: 'Robert'
        fill_in 'Middle name', with: 'Allen'
        fill_in 'Last name', with: 'Testerson'
        fill_in 'Pure ID', with: 'pure-def456'
        fill_in 'Activity Insight ID', with: 'ai-ghi111'
        fill_in 'Penn State ID', with: '123456789'
        check 'Admin user?'
        check 'Show all publications'
        check 'Show all contracts'
        click_on 'Save'
      end

      it "updates the user record's first name" do
        expect(user.reload.first_name).to eq 'Robert'
      end

      it "updates the user record's middle name" do
        expect(user.reload.middle_name).to eq 'Allen'
      end

      it "updates the user record's last name" do
        expect(user.reload.last_name).to eq 'Testerson'
      end

      it "updates the user record's Pure UUID" do
        expect(user.reload.pure_uuid).to eq 'pure-def456'
      end

      it "updates the user record's Activity Insight identifier" do
        expect(user.reload.activity_insight_identifier).to eq 'ai-ghi111'
      end

      it "updates the user record's Penn State ID" do
        expect(user.reload.penn_state_identifier).to eq '123456789'
      end

      it "updates the user record's admin flag" do
        expect(user.reload.is_admin).to be true
      end

      it "updates the user record's publication visibility flag" do
        expect(user.reload.show_all_publications).to be true
      end

      it "updates the user record's contract visibility flag" do
        expect(user.reload.show_all_contracts).to be true
      end

      it 'sets the timestamp on the user record to indicate that it was manually updated' do
        expect(user.reload.updated_by_user_at).not_to be_blank
      end

      it 'redirects back to the user list' do
        expect(page).to have_current_path rails_admin.index_path(model_name: :user), ignore_query: true
      end
    end
  end

  context 'when the current user is not an admin' do
    context 'when the current user manages an organization of the user that is being edited' do
      let!(:member_org) { create :organization, owner: current_user, name: 'Test Org' }

      before do
        create :user_organization_membership, user: user, organization: member_org
        authenticate_user
        visit rails_admin.edit_path(model_name: :user, id: user.id)
      end

      describe 'viewing the edit page' do
        it "shows the user's first name" do
          expect(page).to have_content 'Bob'
        end

        it "shows the user's middle name" do
          expect(page).to have_content 'A.'
        end

        it "shows the user's last name" do
          expect(page).to have_content 'Testuser'
        end

        it "shows the user's WebAccess ID" do
          expect(page).to have_content 'bat123'
        end

        it "shows the user's organization memberships" do
          expect(page).to have_content 'Bob A. Testuser - Test Org'
        end

        it "does not allow the user's webaccess ID to be updated" do
          expect(page).not_to have_field 'Penn State WebAccess ID'
        end

        it "does not allow the user's first name to be updated" do
          expect(page).not_to have_field 'First name'
        end

        it "does not allow the user's middle name to be updated" do
          expect(page).not_to have_field 'Middle name'
        end

        it "does not allow the user's last name to be updated" do
          expect(page).not_to have_field 'Last name'
        end

        it "does not allow the user's admin flag to be updated" do
          expect(page).not_to have_field 'Admin user?'
        end

        it "does not show the user's Pure ID" do
          expect(page).not_to have_content 'pure-abc123'
        end

        it "does not allow the user's Pure ID to be updated" do
          expect(page).not_to have_field 'Pure ID'
        end

        it "does not show the user's Activity Insight ID" do
          expect(page).not_to have_content 'ai-xyz789'
        end

        it "does not allow the user's Activity Insight ID to be updated" do
          expect(page).not_to have_field 'Activity Insight ID'
        end

        it "does not show the user's Penn State ID" do
          expect(page).not_to have_content '987654321'
        end

        it "does not allow the user's Penn State ID to be updated" do
          expect(page).not_to have_field 'Penn State ID'
        end

        it "does not show the user's H-Index" do
          expect(page).not_to have_content '649'
        end

        it "does not allow the user's H-Index to be updated" do
          expect(page).not_to have_field 'H-Index'
          expect(page).not_to have_field 'Scopus h index'
        end
      end

      describe 'submitting the form with new data to update the user record' do
        before do
          check 'Show all publications'
          check 'Show all contracts'
          click_on 'Save'
        end

        it "updates the user record's publication visibility flag" do
          expect(user.reload.show_all_publications).to be true
        end

        it "updates the user record's contract visibility flag" do
          expect(user.reload.show_all_contracts).to be true
        end

        it 'sets the timestamp on the user record to indicate that it was manually updated' do
          expect(user.reload.updated_by_user_at).not_to be_blank
        end
      end
    end

    context 'when the current user does not manage any organizations' do
      before { authenticate_user }

      it 'redirects back to the home page with an error message' do
        visit rails_admin.edit_path(model_name: :user, id: user.id)
        expect(page).to have_current_path root_path, ignore_query: true
        expect(page).to have_content I18n.t('admin.authorization.not_authorized')
      end
    end
  end
end
