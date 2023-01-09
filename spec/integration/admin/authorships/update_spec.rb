# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'updating an authorship via the admin interface', type: :feature do
  let!(:user) do
    create(:user,
           first_name: 'Bob',
           last_name: 'Testuser')
  end

  let!(:pub) { create(:publication, title: 'Test Publication') }

  let!(:auth) do
    create(:authorship,
           publication: pub,
           user: user,
           author_number: 5,
           orcid_resource_identifier: nil,
           confirmed: false)
  end

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.edit_path(model_name: :publication, id: pub.id)
    end

    describe 'submitting the form with new data to update an authorship record' do
      before do
        fill_in 'Orcid resource identifier', with: 'Test Orcid Resource Identifier'
        fill_in 'Author number', with: 2
        check 'Confirmed'
        click_on 'Save'
      end

      it "updates the authorship's data" do
        reloaded_auth = auth.reload
        expect(reloaded_auth.orcid_resource_identifier).to eq 'Test Orcid Resource Identifier'
        expect(reloaded_auth.author_number).to eq 2
        expect(reloaded_auth.confirmed).to be true
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
