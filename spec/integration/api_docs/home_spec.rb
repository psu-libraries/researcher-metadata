# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'support/webdrivers'

describe 'API documentation home page', js: true, type: :feature do
  context 'when the user is logged in' do
    before do
      authenticate_user
      visit 'api_docs'
    end

    it 'shows the home page content' do
      expect(page).to have_content 'Researcher Metadata Database API'
    end

    it 'shows a link to the home page' do
      expect(page).to have_link 'Home', href: root_path
    end

    it 'does not show a link to the Admin interface' do
      expect(page).not_to have_link 'Admin'
    end
  end

  context 'when the user is logged in as an admin' do
    before do
      authenticate_admin_user
      visit 'api_docs'
    end

    it 'shows a link to the home page' do
      expect(page).to have_link 'Home', href: root_path
    end

    it 'shows a link to the Admin interface' do
      expect(page).to have_link 'Admin'
    end
  end

  context 'when the user is not logged in' do
    before { visit 'api_docs' }

    it 'shows the home page content' do
      expect(page).to have_content 'Researcher Metadata Database API'
    end

    it 'shows a link for publications API' do
      expect(page).to have_selector 'a.nostyle span', text: 'publication'
    end

    it 'shows a link for users API' do
      expect(page).to have_selector 'a.nostyle span', text: 'user'
    end

    it 'shows a link for organizations API' do
      expect(page).to have_selector 'a.nostyle span', text: 'organization'
    end

    it 'shows a link to the home page' do
      expect(page).to have_link 'Home', href: root_path
    end

    it 'does not show a link to the Admin interface' do
      expect(page).not_to have_link 'Admin'
    end
  end
end
