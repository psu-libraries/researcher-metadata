# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin internal publication waiver detail page', type: :feature do
  let!(:waiver) { create :internal_publication_waiver, authorship: auth, reason_for_waiver: 'Just because.' }
  let!(:auth) { create :authorship, publication: pub, user: user }
  let!(:user) { create :user, first_name: 'Joe', last_name: 'Testerson' }
  let!(:pub) { create :publication, title: 'Publication One' }
  let!(:ext_waiver) { create :external_publication_waiver,
                             internal_publication_waiver: waiver,
                             publication_title: 'The External Waiver' }

  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      before { visit rails_admin.show_path(model_name: :internal_publication_waiver, id: waiver.id) }

      it 'shows the waiver detail heading' do
        expect(page).to have_content "Details for Internal publication waiver 'Publication One'"
      end

      it 'shows the title of the publication associated with the waiver' do
        expect(page).to have_link 'Publication One', href: rails_admin.show_path(model_name: :publication, id: pub.id)
      end

      it 'shows the name of the user associated with the waiver' do
        expect(page).to have_link 'Joe Testerson', href: rails_admin.show_path(model_name: :user, id: user.id)
      end

      it 'shows the reason for the waiver' do
        expect(page).to have_content 'Just because.'
      end

      it 'show the associated external waiver record' do
        expect(page).to have_link 'The External Waiver'
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.show_path(model_name: :internal_publication_waiver, id: waiver.id) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.show_path(model_name: :internal_publication_waiver, id: waiver.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
