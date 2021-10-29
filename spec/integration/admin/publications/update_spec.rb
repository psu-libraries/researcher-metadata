# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'updating a publication via the admin interface', type: :feature do
  let!(:pub) { create(:publication,
                      title: 'Test Publication') }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.edit_path(model_name: :publication, id: pub.id)
    end

    describe 'viewing the form' do
      it 'does not allow the total Scopus citations to be set' do
        expect(page).not_to have_field 'Total scopus citations'
      end

      it 'shows a nested form for adding open access locations' do
        expect(page).to have_content 'Add a new Open access location'
      end
    end

    describe 'submitting the form with new data to update a publication record' do
      before do
        fill_in 'Title', with: 'Updated Title'
        click_on 'Save'
      end

      it "updates the publication's data" do
        expect(pub.reload.title).to eq 'Updated Title'
      end

      it 'sets the timestamp on the publication to indicate that it was manually updated' do
        expect(pub.reload.updated_by_user_at).not_to be_blank
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.edit_path(model_name: :publication, id: pub.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
