# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'deleting an open access location via the admin interface', type: :feature do
  let!(:oal) { create :open_access_location,
                      source: 'Open Access Button',
                      url: 'https://example.com/test',
                      publication: pub }
  let(:pub) { create :publication }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.delete_path(model_name: :open_access_location, id: oal.id)
    end

    describe 'visiting the form to delete the open access location' do
      it_behaves_like 'a page with the admin layout'

      it 'show the correct content' do
        expect(page).to have_content 'Are you sure you want to delete this open access location'
      end
    end

    describe 'submitting the form to delete the open access location' do
      before { click_button "Yes, I'm sure" }

      it 'destroys the open access location record' do
        expect { oal.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it "redirects to the detail page for the deleted location's publication" do
        expect(page).to have_current_path rails_admin.show_path(model_name: :publication, id: pub.id), ignore_query: true
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.delete_path(model_name: :open_access_location, id: oal.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
