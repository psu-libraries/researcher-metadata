# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'session timeout', :warden_helpers do
  include ActiveSupport::Testing::TimeHelpers

  before do
    authenticate_user
  end

  it 'logs out user after 24 hours of inactivity' do
    visit profile_bio_path
    expect(page).to have_current_path profile_bio_path, ignore_query: true

    travel 24.hours + 1.minute

    visit profile_bio_path
    expect(page).to have_current_path root_path, ignore_query: true
    expect(page).to have_content I18n.t('devise.failure.timeout')
  end

  it 'keeps user logged in within timeout period' do
    visit profile_bio_path
    expect(page).to have_current_path profile_bio_path, ignore_query: true

    travel 23.hours

    visit profile_bio_path
    expect(page).to have_current_path profile_bio_path, ignore_query: true
  end
end
