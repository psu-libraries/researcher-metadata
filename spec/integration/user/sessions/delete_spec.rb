require 'integration/integration_spec_helper'

describe "signing out", :warden_helpers do
  before do
    authenticate_user
  end

  it "ends the user's authenticated session" do
    visit profile_bio_path
    expect(page.current_path).to eq profile_bio_path
    click_link "Sign out"
    expect(page.current_path).to eq root_path
    expect(page).to have_content I18n.t('devise.sessions.signed_out')
    visit profile_bio_path
    expect(page.current_path).to eq root_path
    expect(page).to have_content I18n.t('devise.failure.unauthenticated')
  end
end
