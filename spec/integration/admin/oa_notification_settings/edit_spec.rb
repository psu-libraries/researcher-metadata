# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Oa Notification Settings edit page', type: :feature do
  let!(:settings) { OaNotificationSetting.instance }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.edit_path(model_name: :oa_notification_setting, id: settings.id)
    end

    describe 'visiting the form to edit an Oa Notification Setting' do
      it_behaves_like 'a page with the admin layout'
      it 'show the correct content' do
        expect(page).to have_content 'Edit Oa notification setting'
      end

      it 'does not allow the singleton_guard value to be set' do
        expect(page).not_to have_field 'Singleton guard'
      end
    end

    describe 'submitting the form to update an Oa Notification Setting' do
      before do
        fill_in 'Email cap', with: 400
        uncheck 'Is active'

        click_button 'Save'
      end

      it 'saves the new Oa Notification Setting data' do
        o = OaNotificationSetting.instance
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