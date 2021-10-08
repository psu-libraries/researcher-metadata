# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin ScholarSphere work deposits list', type: :feature do
  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      let!(:deposit1) { create(:scholarsphere_work_deposit, status: 'Pending', authorship: auth1) }
      let!(:deposit2) { create(:scholarsphere_work_deposit, status: 'Failed', authorship: auth2) }
      let(:auth1) { create(:authorship) }
      let(:auth2) { create(:authorship) }

      before { visit rails_admin.index_path(model_name: :scholarsphere_work_deposit) }

      it 'shows the list heading' do
        expect(page).to have_content 'List of Scholarsphere work deposits'
      end

      it 'shows information about each deposit' do
        expect(page).to have_content deposit1.id
        expect(page).to have_content 'Pending'
        expect(page).to have_link auth1.id, href: rails_admin.show_path(model_name: :authorship, id: auth1.id)

        expect(page).to have_content deposit2.id
        expect(page).to have_content 'Failed'
        expect(page).to have_link auth2.id, href: rails_admin.show_path(model_name: :authorship, id: auth2.id)
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.index_path(model_name: :scholarsphere_work_deposit) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.index_path(model_name: :scholarsphere_work_deposit)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
