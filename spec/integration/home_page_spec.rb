require 'integration/integration_spec_helper'

feature "Home page", type: :feature do
  scenario "visit" do
    visit root_path
    expect(page).to have_content "PSU Libraries Research Metadata"
  end
end
