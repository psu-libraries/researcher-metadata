# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'updating a performance via the admin interface', type: :feature do
  let!(:perf) { create(:performance, visible: false) }

  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe "changing the performance's visibility" do
      before do
        visit rails_admin.edit_path(model_name: :performance, id: perf.id)
        check 'Visible via API?'
        click_on 'Save'
      end

      it "updates the performance's visibility" do
        expect(perf.reload.visible).to eq true
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.edit_path(model_name: :performance, id: perf.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
