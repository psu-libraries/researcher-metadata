# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin ScholarSphere work deposit detail page', type: :feature do
  let!(:deposit) { create(:scholarsphere_work_deposit,
                          authorship: auth,
                          status: 'Success',
                          error_message: 'No errors occurred.',
                          deposited_at: Time.new(2021, 4, 2, 16, 46, 0, '-00:00'),
                          title: 'Test Work',
                          description: 'A description',
                          published_date: Date.new(2020, 12, 20),
                          embargoed_until: Date.new(2022, 1, 1),
                          rights: 'https://rightsstatements.org/page/InC/1.0/') }
  let!(:auth) { create(:authorship) }
  let!(:upload) { create(:scholarsphere_file_upload, work_deposit: deposit) }

  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      before { visit rails_admin.show_path(model_name: :scholarsphere_work_deposit, id: deposit.id) }

      it 'shows the correct data for the deposit' do
        expect(page).to have_link "##{auth.id} (Test User - Test)", href: rails_admin.show_path(model_name: :authorship, id: auth.id)
        expect(page).to have_content 'Status'
        expect(page).to have_content 'No errors occurred.'
        expect(page).to have_content 'April 02, 2021 16:46'
        expect(page).to have_content 'Test Work'
        expect(page).to have_content 'A description'
        expect(page).to have_content 'December 20, 2020'
        expect(page).to have_content 'January 01, 2022'
        expect(page).to have_content 'https://rightsstatements.org/page/InC/1.0/'
        expect(page).to have_link(
          "ScholarsphereFileUpload ##{upload.id}",
          href: rails_admin.show_path(model_name: :scholarsphere_file_upload, id: upload.id)
        )
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.show_path(model_name: :scholarsphere_work_deposit, id: deposit.id) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.show_path(model_name: :scholarsphere_work_deposit, id: deposit.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
