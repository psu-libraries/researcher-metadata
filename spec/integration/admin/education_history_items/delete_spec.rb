# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'deleting an education history item via the admin interface', type: :feature do
  let!(:ehi) { create(:education_history_item,
                      user: user) }
  let(:user) { create(:user) }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.delete_path(model_name: :education_history_item, id: ehi.id)
    end

    describe 'visiting the form to delete the education history item' do
      it_behaves_like 'a page with the admin layout'

      it 'show the correct content' do
        expect(page).to have_content 'Are you sure you want to delete this education history item'
      end
    end

    describe 'submitting the form to delete the education history item' do
      before { click_button "Yes, I'm sure" }

      it 'destroys the education history item' do
        expect { ehi.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it "redirects to the detail page for the deleted item's user" do
        expect(page).to have_current_path rails_admin.show_path(model_name: :user, id: user.id), ignore_query: true
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.delete_path(model_name: :education_history_item, id: ehi.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end