# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'updating a activity insight oa file via the admin interface', type: :feature do
  let!(:aif) { create(:activity_insight_oa_file, publication: pub) }
  let(:pub) {
    create(
      :publication,
      title: 'Test Publication',
      doi: 'https://doi.org/10.123/test',
      journal_title: 'Test Journal'
    )
  }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.edit_path(model_name: :activity_insight_oa_file, id: aif.id)
    end

    describe 'viewing the form' do
      it 'does not allow the location to be set' do
        expect(page).to have_no_field 'Location'
        expect(page).to have_content aif.location
      end

      it 'shows a form for version' do
        expect(page).to have_field 'Version'
      end

      it 'shows useful metadata about the associated publication' do
        expect(page).to have_link 'Test Publication'
        expect(page).to have_content 'https://doi.org/10.123/test'
        expect(page).to have_content 'Test Journal'
      end
    end

    describe 'submitting the form with new data to update a publication record' do
      before do
        select 'unknown', from: 'Version'
        select 'Public Domain Mark 1.0', from: 'License'
        fill_in 'Set statement', with: 'test statement'
        find_by_id('activity_insight_oa_file_checked_for_set_statement_1').click
        fill_in 'Embargo date', with: 'September 04, 2023'
        find_by_id('activity_insight_oa_file_checked_for_embargo_date_1').click
        click_on 'Save'
      end

      it "updates the activity insight oa file's data" do
        f = aif.reload
        expect(f.version).to eq 'unknown'
        expect(f.license).to eq 'http://creativecommons.org/publicdomain/mark/1.0/'
        expect(f.set_statement).to eq 'test statement'
        expect(f.checked_for_set_statement).to be true
        expect(f.embargo_date).to eq Date.new(2023, 9, 4)
        expect(f.checked_for_embargo_date).to be true
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.edit_path(model_name: :activity_insight_oa_file, id: aif.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
