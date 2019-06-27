require 'integration/integration_spec_helper'

feature "Profile page", type: :feature do
  before do
    create :user,
           webaccess_id: 'abc123',
           first_name: 'Bob',
           last_name: 'Testuser'
  end

  it "shows the name of the requested user" do
    visit profile_path(webaccess_id: 'abc123')

    expect(page).to have_content "Bob Testuser"
  end
end
