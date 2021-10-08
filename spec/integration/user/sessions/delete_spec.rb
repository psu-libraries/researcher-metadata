# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'signing out', :warden_helpers do
  before do
    authenticate_user
  end

  it "ends the user's authenticated session" do
    visit profile_bio_path
    expect(page).to have_current_path profile_bio_path, ignore_query: true
    click_link 'Sign out'
    expect(page).to have_current_path root_path, ignore_query: true
    expect(page).to have_content I18n.t('devise.sessions.signed_out')
    visit profile_bio_path
    expect(page).to have_current_path root_path, ignore_query: true
    expect(page).to have_content I18n.t('devise.failure.unauthenticated')
  end
end
