# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'OA Notification Settings show page', type: :feature do
  let!(:settings) { OANotificationSetting.instance }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.show_path(model_name: :oa_notification_setting, id: settings.id)
    end

    describe 'visiting the page to view an OA Notification Setting' do
      it 'show the correct content' do
        expect(page).to have_content 'Details for OA notification setting'
        expect(page).to have_content settings.email_cap
        expect(page).to have_css 'span.fa-check', count: 1
        expect(page).not_to have_content 'Singleton guard'
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.show_path(model_name: :oa_notification_setting, id: settings.id) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.show_path(model_name: :oa_notification_setting, id: settings.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
