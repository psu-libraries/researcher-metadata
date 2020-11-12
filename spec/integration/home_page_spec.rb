require 'integration/integration_spec_helper'

feature "Home page", type: :feature do
  let(:home_content) { "Researcher Metadata" }

  shared_examples_for "a page with the public layout" do

    it "shows a link to the admin interface" do
      expect(page).to have_link 'Admin', href: rails_admin_path
    end

    it "shows a link to the profile page" do
      expect(page).to have_link 'Profile', href: profile_bio_path
    end

    it "shows a link to the home page" do
      expect(page).to have_link 'Home', href: root_path
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

    it "shows an email link" do
      expect(page).to have_link 'Learn More', href: "mailto:L-FAMS@lists.psu.edu?Subject=RMD%20Inquiry"
    end

    it "shows a link to the API documentation" do
      expect(page).to have_link 'API Documentation', href: swagger_ui_engine_path
    end

    it "shows a link to the developer resources page" do
      expect(page).to have_link 'Build Profiles', href: resources_path
    end

    it_behaves_like "a page with the public layout"
  end

  context "when the user is not logged in" do
    before { visit root_path }

    it "shows the home page content" do
      expect(page).to have_content home_content
    end

    it "shows an email link" do
      expect(page).to have_link 'Learn More', href: "mailto:L-FAMS@lists.psu.edu?Subject=RMD%20Inquiry"
    end

    it "shows a link to the API documentation" do
      expect(page).to have_link 'API Documentation', href: swagger_ui_engine_path
    end

    it "shows a link to the developer resources page" do
      expect(page).to have_link 'Build Profiles', href: resources_path
    end

    it_behaves_like "a page with the public layout"
  end
end
