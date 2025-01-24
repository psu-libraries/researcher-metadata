# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'OA Notification Settings edit page', type: :feature do
  let!(:settings) { OANotificationSetting.instance }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.edit_path(model_name: :oa_notification_setting, id: settings.id)
    end

    describe 'visiting the form to edit an OA Notification Setting' do
      it_behaves_like 'a page with the admin layout'
      it 'show the correct content' do
        expect(page).to have_content 'Edit OA notification setting'
      end

      it 'does not allow the singleton_guard value to be set' do
        expect(page).not_to have_field 'Singleton guard'
      end
    end

    describe 'submitting the form to update an OA Notification Setting' do
      before do
        fill_in 'Email cap', with: 400
        find_by_id('oa_notification_setting_is_active_0').click

        click_button 'Save'
      end

      it 'saves the new OA Notification Setting data' do
        o = OANotificationSetting.instance
        expect(o.email_cap).to be 400
        expect(o.is_active).to be false
        expect(o.singleton_guard).to be 0
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.edit_path(model_name: :oa_notification_setting, id: settings.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
