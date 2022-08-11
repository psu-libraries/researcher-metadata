# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'updating a presentation via the admin interface', type: :feature do
  let!(:pres) { create(:presentation, visible: false) }

  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe "changing the presentation's visibility" do
      before do
        visit rails_admin.edit_path(model_name: :presentation, id: pres.id)
        check 'Visible via API?'
        click_on 'Save'
      end

      it "updates the presentation's visibility" do
        expect(pres.reload.visible).to be true
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.edit_path(model_name: :presentation, id: pres.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
