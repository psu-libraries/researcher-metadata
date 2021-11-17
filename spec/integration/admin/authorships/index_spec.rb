# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin authorships list', type: :feature do
  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    describe 'the page content' do
      let(:pub1) { create(:publication, title: 'First Publication') }
      let(:pub2) { create(:publication, title: 'Second Publication') }
      let(:user1) { create(:user, first_name: 'Susan', last_name: 'Tester') }
      let(:user2) { create(:user, first_name: 'Bob', last_name: 'User') }
      let!(:auth1) { create(:authorship, user: user1, publication: pub1) }
      let!(:auth2) { create(:authorship, user: user2, publication: pub2) }

      before { visit rails_admin.index_path(model_name: :authorship) }

      it 'shows the authorship list heading' do
        expect(page).to have_content 'List of Authorships'
      end

      it 'shows information about each authorship' do
        expect(page).to have_content auth1.id
        expect(page).to have_link 'First Publication', href: rails_admin.show_path(model_name: :publication, id: pub1.id)
        expect(page).to have_link 'Susan Tester', href: rails_admin.show_path(model_name: :user, id: user1.id)

        expect(page).to have_content auth2.id
        expect(page).to have_link 'Second Publication', href: rails_admin.show_path(model_name: :publication, id: pub2.id)
        expect(page).to have_link 'Bob User', href: rails_admin.show_path(model_name: :user, id: user2.id)
      end

      it 'shows a link to show all authorships' do
        expect(page).to have_link 'All'
      end

      it 'shows a link to show only authorships that are claimed and unconfirmed' do
        expect(page).to have_link 'Claimed And Unconfirmed'
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.index_path(model_name: :authorship) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.index_path(model_name: :authorship)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
