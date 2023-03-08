# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin open access location detail page', type: :feature do
  let!(:oal) { create(:open_access_location,
                      publication: pub,
                      host_type: 'publisher',
                      license: 'cc-by-nc',
                      oa_date: Date.new(2020, 5, 3),
                      source: Source::UNPAYWALL,
                      source_updated_at: Time.new(2021, 10, 7, 18, 7, 0, '+00:00'),
                      url: 'https://nature.com/articles/testpub123',
                      landing_page_url: 'https://nature.com/articles/testpub123/info',
                      pdf_url: 'https://nature.com/articles/testpub123/pdf',
                      version: 'publishedVersion') }

  let(:pub) { create(:publication, title: 'Test Pub') }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
    end

    describe 'the page content' do
      before { visit rails_admin.show_path(model_name: :open_access_location, id: oal.id) }

      it 'shows the correct data for the location' do
        expect(page).to have_content "Details for Open access location '#{oal.name}'"
        expect(page).to have_content 'publisher'
        expect(page).to have_content 'cc-by-nc'
        expect(page).to have_content 'May 03, 2020'
        expect(page).to have_content 'Unpaywall'
        expect(page).to have_content 'October 07, 2021 18:07'
        expect(page).to have_link 'https://nature.com/articles/testpub123', href: 'https://nature.com/articles/testpub123'
        expect(page).to have_link 'https://nature.com/articles/testpub123/info', href: 'https://nature.com/articles/testpub123/info'
        expect(page).to have_link 'https://nature.com/articles/testpub123/pdf', href: 'https://nature.com/articles/testpub123/pdf'
        expect(page).to have_content 'publishedVersion'
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.show_path(model_name: :open_access_location, id: oal.id) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.show_path(model_name: :open_access_location, id: oal.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
