require 'integration/integration_spec_helper'

describe "editing profile preferences" do
  let!(:user) { create :user,
                       webaccess_id: 'abc123',
                       first_name: 'Bob',
                       last_name: 'Testuser',
                       show_all_publications: true }
  let!(:other_user) { create :user, webaccess_id: 'xyz789'}
  let!(:pub) { create :publication, title: "Bob's Publication", visible: true }
  let!(:auth) { create :authorship, publication: pub, user: user, visible_in_profile: false }

  feature "the manage profile link", type: :feature do
    describe "visiting the profile page for a given user" do
      context "when not logged in" do
        before { visit profile_path(webaccess_id: 'abc123') }

        it "does not display a link to manage the profile" do
          expect(page).to_not have_link "Manage my profile"
        end
      end
      context "when logged in as that user" do
        before do
          authenticate_as(user)
          visit profile_path(webaccess_id: 'abc123')
        end

        it "displays a link to manage the profile" do
          expect(page).to have_link "Manage my profile", href: edit_profile_path
        end
      end
      context "when logged in as a different user" do
        before do
          authenticate_as(other_user)
          visit profile_path(webaccess_id: 'abc123')
        end

        it "does not display a link to manage the profile" do
          expect(page).to_not have_link "Manage my profile"
        end
      end
    end
  end

  feature "the profile edit page" do
    before do
      authenticate_as(user)
      visit edit_profile_path
    end

    it "shows the name of the user" do
      expect(page).to have_content "Bob Testuser"
    end

    it "shows the names of the user's publications" do
      expect(page).to have_content "Bob's Publication"
    end
  end
end
