# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Creating an authorship', type: :feature do
  let!(:user) { create :user, first_name: 'Emily', last_name: 'Researcher' }
  let!(:pub) { create :publication, title: 'New Scientific Research' }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.new_path(model_name: :authorship)
    end

    describe 'visiting the form to create a new authorship' do
      it_behaves_like 'a page with the admin layout'
      it 'show the correct content' do
        expect(page).to have_content 'New Authorship'
      end
    end

    describe 'submitting the form to create a new authorship', js: true do
      before do
        within '#authorship_user_id_field' do
          find('.dropdown-toggle').click
        end
        find('a', text: 'Emily Researcher').click
        within '#authorship_publication_id_field' do
          find('.dropdown-toggle').click
        end
        find('a', text: 'New Scientific Research').click
        fill_in 'Author number', with: 2
        check 'Confirmed'

        click_button 'Save'
      end

      it 'creates a new authorship record in the database with the provided data' do
        a = Authorship.find_by(user: user, publication: pub)

        expect(a.author_number).to eq 2
        expect(a.confirmed).to be true
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.new_path(model_name: :authorship)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
