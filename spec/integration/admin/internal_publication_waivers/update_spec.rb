# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'updating an internal publication waiver via the admin interface', type: :feature do
  let!(:waiver) { create(:internal_publication_waiver,
                         authorship: authorship,
                         reason_for_waiver: 'because') }
  let!(:authorship) { create(:authorship, user: user, publication: pub) }
  let!(:user) { create(:user, first_name: 'James', last_name: 'Testington') }
  let!(:pub) { create(:publication, title: 'A Test Publication') }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.edit_path(model_name: :internal_publication_waiver, id: waiver.id)
    end

    describe 'viewing the edit page' do
      it 'shows a link to the user associated with the waiver' do
        expect(page).to have_link 'James Testington', href: rails_admin.show_path(model_name: :user, id: user.id)
      end

      it 'shows a link to the publication associated with the waiver' do
        expect(page).to have_link 'A Test Publication', href: rails_admin.show_path(model_name: :publication, id: pub.id)
      end
    end

    describe 'submitting the form with new data to update the waiver record' do
      before do
        fill_in 'Reason for waiver', with: 'new reason'
        click_button 'Save'
      end

      it "updates the waiver record's reason" do
        expect(waiver.reload.reason_for_waiver).to eq 'new reason'
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.edit_path(model_name: :internal_publication_waiver, id: waiver.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
