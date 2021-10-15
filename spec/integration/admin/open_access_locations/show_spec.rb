# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin open access location detail page', type: :feature do
  let!(:oal) { create :open_access_location,
                      publication: pub,
                      host_type: 'publisher',
                      license: 'cc-by-nc',
                      oa_date: Date.new(2020, 5, 3),
                      source: 'Unpaywall',
                      source_updated_at: Time.new(2021, 10, 7, 18, 7, 0, '+00:00'),
                      url: 'https://nature.com/articles/testpub123',
                      landing_page_url: 'https://nature.com/articles/testpub123/info',
                      pdf_url: 'https://nature.com/articles/testpub123/pdf',
                      version: 'publishedVersion' }

  let(:pub) { create :publication, title: 'Test Pub' }

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
    end

    describe 'the page content' do
      before { visit rails_admin.show_path(model_name: :open_access_location, id: oal.id) }

      it 'shows the location detail heading' do
        expect(page).to have_content "Details for Open access location 'https://nature.com/articles/testpub123 (Unpaywall)'"
      end

      it "shows the location's host type" do
        expect(page).to have_content 'publisher'
      end

      it "shows the location's license" do
        expect(page).to have_content 'cc-by-nc'
      end

      it "shows the location's open access date" do
        expect(page).to have_content 'May 03, 2020'
      end

      it "shows the location's data source" do
        expect(page).to have_content 'Unpaywall'
      end

      it "shows the location's data source update time" do
        expect(page).to have_content 'October 07, 2021 18:07'
      end

      it "shows the location's url" do
        expect(page).to have_link 'https://nature.com/articles/testpub123', href: 'https://nature.com/articles/testpub123'
      end

      it "shows the location's landing page url" do
        expect(page).to have_link 'https://nature.com/articles/testpub123/info', href: 'https://nature.com/articles/testpub123/info'
      end

      it "shows the location's pdf url" do
        expect(page).to have_link 'https://nature.com/articles/testpub123/pdf', href: 'https://nature.com/articles/testpub123/pdf'
      end

      it "shows the location's version" do
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
