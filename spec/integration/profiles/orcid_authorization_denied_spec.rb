require 'integration/integration_spec_helper'

describe 'The landing page that a user sees when they deny authorization to connect to ORCID', type: :feature do
  let!(:user) { create :user }

  before do
    authenticate_as(user)
    visit orcid_access_token_path(params: { error: 'access_denied' })
  end

  it 'shows a message saying that the user denied authorization' do
    expect(page).to have_content I18n.t('profile.orcid_access_tokens.create.authorization_denied')
  end

  it 'shows the correct content' do
    expect(page).to have_content 'Why Connect?'
  end

  it 'shows a button to try to authorize the ORCID connection again' do
    expect(page).to have_button 'I changed my mind, connect my ORCID iD'
  end

  it 'shows a link to return to the profile bio management page' do
    expect(page).to have_link 'Return to my profile', href: profile_bio_path
  end

  it "shows a link to ORCID's privacy policy" do
    expect(page).to have_link 'privacy policy', href: 'https://orcid.org/privacy-policy'
  end
end
