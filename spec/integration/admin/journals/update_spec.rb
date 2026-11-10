# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin journal edit page', type: :feature do
  let!(:journal) { create(:journal,
                          title: 'Test Journal',
                          pure_uuid: 'pure-abc-123') }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.edit_path(model_name: :journal, id: journal.id)
    end

    describe 'submitting the form without any changes' do
      before { click_on 'Save' }

      it 'does not update edited_manually field' do
        expect(journal.edited_manually).to be false
      end
    end

    describe 'submitting the form with changes made' do
      before do
        fill_in 'Title', with: 'Test Journal Title'
        click_on 'Save'
      end

      it 'does update edited_manually field' do
        reloaded_journal = journal.reload
        expect(reloaded_journal.edited_manually).to be true
      end
    end
  end

  context 'when the user is not an admin' do
    before do
      authenticate_user
      visit rails_admin.edit_path(model_name: :journal, id: journal.id)
    end

    it 'redirects back to the home page with an error message' do
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
