# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'Home page', type: :feature do
  let(:home_content) { 'Researcher Metadata' }

  shared_examples_for 'a page with the public layout' do
    it 'shows a link to the profile page' do
      expect(page).to have_link 'Profile', href: profile_bio_path
    end

    it 'shows a link to the home page' do
      expect(page).to have_link 'Home', href: root_path
    end
  end

  context 'when a regular user is logged in' do
    before do
      authenticate_user
      visit root_path
    end

    it 'shows the home page content' do
      expect(page).to have_content home_content
    end

    it 'shows a link to the open access policy' do
      expect(page).to have_link "Penn State's open access policy", href: 'https://openaccess.psu.edu/'
    end

    it 'shows a link to the wiki' do
      expect(page).to have_link 'Learn More', href: 'https://github.com/psu-libraries/researcher-metadata/wiki'
    end

    it 'shows a link to the API documentation' do
      expect(page).to have_link 'API Documentation', href: '/api_docs'
    end

    it 'shows a link to the developer resources page' do
      expect(page).to have_link 'Build Profiles', href: resources_path
    end

    it 'does not show a link to the admin interface' do
      expect(page).not_to have_link 'Admin'
    end

    it 'shows a sign out link' do
      expect(page).to have_link 'Sign out', href: destroy_user_session_path
    end

    it_behaves_like 'a page with the public layout'
  end

  context 'when an admin user is logged in' do
    before do
      authenticate_admin_user
      visit root_path
    end

    it 'shows the home page content' do
      expect(page).to have_content home_content
    end

    it 'shows a link to the open access policy' do
      expect(page).to have_link "Penn State's open access policy", href: 'https://openaccess.psu.edu/'
    end

    it 'shows a link to the wiki' do
      expect(page).to have_link 'Learn More', href: 'https://github.com/psu-libraries/researcher-metadata/wiki'
    end

    it 'shows a link to the API documentation' do
      expect(page).to have_link 'API Documentation', href: '/api_docs'
    end

    it 'shows a link to the developer resources page' do
      expect(page).to have_link 'Build Profiles', href: resources_path
    end

    it 'shows a link to the admin interface' do
      expect(page).to have_link 'Admin', href: rails_admin_path
    end

    it 'shows a sign out link' do
      expect(page).to have_link 'Sign out', href: destroy_user_session_path
    end

    it_behaves_like 'a page with the public layout'
  end

  context 'when the user is not logged in' do
    before { visit root_path }

    it 'shows the home page content' do
      expect(page).to have_content home_content
    end

    it 'shows a link to the open access policy' do
      expect(page).to have_link "Penn State's open access policy", href: 'https://openaccess.psu.edu/'
    end

    it 'shows a link to the wiki' do
      expect(page).to have_link 'Learn More', href: 'https://github.com/psu-libraries/researcher-metadata/wiki'
    end

    it 'shows a link to the API documentation' do
      expect(page).to have_link 'API Documentation', href: '/api_docs'
    end

    it 'shows a link to the developer resources page' do
      expect(page).to have_link 'Build Profiles', href: resources_path
    end

    it 'does not show a link to the admin interface' do
      expect(page).not_to have_link 'Admin'
    end

    it 'does not show a sign out link' do
      expect(page).not_to have_link 'Sign out'
    end

    it_behaves_like 'a page with the public layout'
  end
end
