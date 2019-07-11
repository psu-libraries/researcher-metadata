require 'integration/integration_spec_helper'

describe "editing profile preferences" do
  let!(:user) { create :user,
                       webaccess_id: 'abc123',
                       first_name: 'Bob',
                       last_name: 'Testuser',
                       show_all_publications: true,
                       orcid_identifier: orcid_id }
  let!(:other_user) { create :user, webaccess_id: 'xyz789'}
  let!(:pub_1) { create :publication,
                        title: "Bob's Publication",
                        visible: true,
                        journal_title: "The Journal",
                        published_on: Date.new(2007, 1, 1) }
  let!(:pub_2) { create :publication,
                        title: "Bob's Other Publication",
                        visible: false }
  let!(:auth_1) { create :authorship, publication: pub_1, user: user, visible_in_profile: false }
  let!(:auth_2) { create :authorship, publication: pub_2, user: user, visible_in_profile: false }
  let(:orcid_id) { nil }

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
          expect(page).to have_link "Manage my profile", href: edit_profile_publications_path
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

  feature "the ORCID link", type: :feature do
    describe "visiting the profile page for a given user" do
      context "when not logged in" do
        before { visit profile_path(webaccess_id: 'abc123') }

        context "when the user has no ORCID ID" do
          it "does not display an ORCID ID link" do
            expect(page).to_not have_link "ORCID iD"
          end

          it "does not display an ORCID call to action" do
            expect(page).to_not have_link "Link my ORCID ID"
          end
        end
        context "when the user has an ORCID ID" do
          let(:orcid_id) { 'https://orcid.org/my-orcid-id' }

          it "displays an ORCID ID link" do
            expect(page).to have_link "ORCID iD", href: 'https://orcid.org/my-orcid-id'
          end

          it "does not display an ORCID call to action" do
            expect(page).to_not have_link "Link my ORCID ID"
          end
        end
      end
      context "when logged in as that user" do
        before do
          authenticate_as(user)
          visit profile_path(webaccess_id: 'abc123')
        end

        context "when the user has no ORCID ID" do
          it "does not display an ORCID ID link" do
            expect(page).to_not have_link "ORCID iD"
          end

          it "does displays an ORCID call to action" do
            expect(page).to have_link "Link my ORCID ID", href: 'https://guides.libraries.psu.edu/orcid'
          end
        end
        context "when the user has an ORCID ID" do
          let(:orcid_id) { 'https://orcid.org/my-orcid-id' }

          it "displays an ORCID ID link" do
            expect(page).to have_link "ORCID iD", href: 'https://orcid.org/my-orcid-id'
          end

          it "does not display an ORCID call to action" do
            expect(page).to_not have_link "Link my ORCID ID"
          end
        end
      end
      context "when logged in as a different user" do
        before do
          authenticate_as(other_user)
          visit profile_path(webaccess_id: 'abc123')
        end

        context "when the user has no ORCID ID" do
          it "does not display an ORCID ID link" do
            expect(page).to_not have_link "ORCID iD"
          end

          it "does not display an ORCID call to action" do
            expect(page).to_not have_link "Link my ORCID ID"
          end
        end
        context "when the user has an ORCID ID" do
          let(:orcid_id) { 'https://orcid.org/my-orcid-id' }

          it "displays an ORCID ID link" do
            expect(page).to have_link "ORCID iD", href: 'https://orcid.org/my-orcid-id'
          end

          it "does not display an ORCID call to action" do
            expect(page).to_not have_link "Link my ORCID ID"
          end
        end
      end
    end
  end

  feature "the profile publications edit page" do
    before do
      authenticate_as(user)
      visit edit_profile_publications_path
    end

    it "shows a link to return to the public profile" do
      expect(page).to have_link "Back to Public Profile", href: profile_path(webaccess_id: user.webaccess_id)
    end
    it "shows the name of the user" do
      expect(page).to have_content "Bob Testuser"
    end

    it "shows descriptions of the user's visible publications" do
      expect(page).to have_content "Bob's Publication - The Journal - 2007"
      expect(page).to_not have_content "Bob's Other Publication"
    end
  end
end
