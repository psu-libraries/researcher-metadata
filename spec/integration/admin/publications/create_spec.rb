# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Creating a publication', type: :feature do
  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.new_path(model_name: :publication)
    end

    describe 'visiting the form to create a new publication' do
      it_behaves_like 'a page with the admin layout'
      it 'show the correct content' do
        expect(page).to have_content 'New Publication'
        expect(page).to have_content /add a new open access location/i
      end

      it 'does not allow the total Scopus citations to be set' do
        expect(page).not_to have_field 'Total scopus citations'
      end
    end

    describe 'submitting the form to create a new publication' do
      before do
        fill_in 'Title', with: 'Test Publication'
        fill_in 'Secondary title', with: 'Test Subtitle'
        select 'Journal Article', from: 'Publication type'
        fill_in 'Journal title', with: 'Test Journal'
        fill_in 'Status', with: 'Published'
        fill_in 'Volume', with: 'Test Volume'
        fill_in 'Issue', with: 'Test Issue'
        fill_in 'Edition', with: 'Test Edition'
        fill_in 'Page range', with: 'Test Range'
        fill_in 'ISSN', with: 'Test ISSN'
        fill_in 'DOI', with: 'https://doi.org/10.000/test'
        fill_in 'Abstract', with: 'Test Abstract'
        check 'Et al authors?'
        fill_in 'Published on', with: 'August 23, 2018'
        check 'Visible via API?'

        click_button 'Save'
      end

      it 'creates a new publication record in the database with the provided data' do
        p = Publication.find_by(title: 'Test Publication')
        expect(p.secondary_title).to eq 'Test Subtitle'
        expect(p.publication_type).to eq 'Journal Article'
        expect(p.journal_title).to eq 'Test Journal'
        expect(p.status).to eq 'Published'
        expect(p.volume).to eq 'Test Volume'
        expect(p.issue).to eq 'Test Issue'
        expect(p.edition).to eq 'Test Edition'
        expect(p.page_range).to eq 'Test Range'
        expect(p.issn).to eq 'Test ISSN'
        expect(p.doi).to eq 'https://doi.org/10.000/test'
        expect(p.abstract).to eq 'Test Abstract'
        expect(p.authors_et_al).to eq true
        expect(p.published_on).to eq Date.new(2018, 8, 23)
        expect(p.visible).to eq true
      end

      it 'marks the new publication as having been manually edited' do
        p = Publication.find_by(title: 'Test Publication')
        expect(p.updated_by_user_at).not_to be_nil
      end
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.new_path(model_name: :publication)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
