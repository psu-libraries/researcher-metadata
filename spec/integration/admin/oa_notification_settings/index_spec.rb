# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin OA Notification Settings list', type: :feature do
  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      let!(:setting) { OANotificationSetting.instance }

      before { visit rails_admin.index_path(model_name: :oa_notification_setting) }

      it 'shows the OA Notification Settings list heading' do
        expect(page).to have_content 'List of OA notification settings'
      end

      it 'shows information about each OA Notification Setting' do
        expect(page).to have_content setting.email_cap
        expect(page).to have_css 'span.fa-check', count: 1
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.index_path(model_name: :oa_notification_setting) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.index_path(model_name: :oa_notification_setting)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
