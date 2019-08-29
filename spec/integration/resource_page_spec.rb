require 'integration/integration_spec_helper'

feature "Resource page", type: :feature do
  let(:page_content) { "Check out our template" }

  context "when the user is logged in" do
    before do
      authenticate_user
      visit resources_path
    end

    it "shows the page content" do
      expect(page).to have_content page_content
    end

    it "provides a link to the profile demo" do
      expect(page).to have_link 'Visit the live demo'
    end

    it "provides a link to download code" do
      expect(page).to have_link 'Download code'
    end
  end

  context "when the user is not logged in" do
    before { visit resources_path }

    it "shows the page content" do
      expect(page).to have_content page_content
    end

    it "provides a link to the profile demo" do
      expect(page).to have_link 'Visit the live demo'
    end

    it "provides a link to download code" do
      expect(page).to have_link 'Download code'
    end
  end
end
