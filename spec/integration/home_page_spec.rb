require 'integration/integration_spec_helper'

feature "Home page", type: :feature do
  let(:home_content) { "Research Metadata" }

  shared_examples_for "a page with the public layout" do

    it "shows a link to the home page" do
      expect(page).to have_link 'Home', href: root_path
    end

    it "shows a link to the API documentation" do
      expect(page).to have_link 'API'
    end

    it "shows a link to the admin interface" do
      expect(page).to have_link 'Admin'
    end
  end

  context "when the user is logged in" do
    before do
      authenticate_user
      visit root_path
    end

    it "shows the home page content" do
      expect(page).to have_content home_content
    end

    it_behaves_like "a page with the public layout"
  end

  context "when the user is not logged in" do
    before { visit root_path }

    it "shows the home page content" do
      expect(page).to have_content home_content
    end

    it_behaves_like "a page with the public layout"
  end
end
