require 'integration/integration_spec_helper'

feature "Home page", type: :feature do
  let(:home_content) { "PSU Libraries Research Metadata" }

  context "when the user is logged in" do
    before { authenticate_user }

    it "shows the home page content" do
      visit root_path
      expect(page).to have_content home_content
    end
  end
end
