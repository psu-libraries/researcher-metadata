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
  let!(:pres1) { create :presentation,
                        title: "Bob's Presentation",
                        organization: "Penn State",
                        location: "University Park, PA",
                        visible: true }
  let!(:pres2) { create :presentation,
                        title: "Bob's Other Presentation",
                        visible: false }
  let!(:cont_1) { create :presentation_contribution,
                         presentation: pres1,
                         user: user,
                         visible_in_profile: false }
  let!(:cont_2) { create :presentation_contribution,
                         presentation: pres2,
                         user: user,
                         visible_in_profile: false }
  let!(:perf_1) { create :performance,
                         title: "Bob's Performance",
                         location: "University Park, PA",
                         start_on: Date.new(2000, 1, 1),
                         visible: true }
  let!(:perf_2) { create :performance,
                         title: "Bob's Other Performance",
                         visible: true }
  let!(:up_1) { create :user_performance,
                       performance: perf_1,
                       user: user }
  let!(:up_2) { create :user_performance,
                       performance: perf_2,
                       user: user }
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

  shared_examples_for "a profile management page" do
    it "shows a link to return to the public profile" do
      expect(page).to have_link "Back to Public Profile", href: profile_path(webaccess_id: user.webaccess_id)
    end

    it "shows a link to the edit profile publications page" do
      expect(page).to have_link "Publications", href: edit_profile_publications_path
    end

    it "shows a link to the edit profile presentations page" do
      expect(page).to have_link "Presentations", href: edit_profile_presentations_path
    end

    it "shows a link to the edit profile performances page" do
      expect(page).to have_link "Performances", href: edit_profile_performances_path
    end
  end

  feature "the profile publications edit page" do
    before do
      authenticate_as(user)
      visit edit_profile_publications_path
    end

    it_behaves_like "a profile management page"

    it "shows the correct heading content" do
      expect(page).to have_content "Publications for Bob Testuser"
    end

    it "shows descriptions of the user's visible publications" do
      expect(page).to have_content "Bob's Publication - The Journal - 2007"
      expect(page).to_not have_content "Bob's Other Publication"
    end
  end

  feature "the profile presentations edit page" do
    before do
      authenticate_as(user)
      visit edit_profile_presentations_path
    end

    it_behaves_like "a profile management page"

    it "shows the correct heading content" do
      expect(page).to have_content "Presentations for Bob Testuser"
    end

    it "shows descriptions of the user's visible presentations" do
      expect(page).to have_content "Bob's Presentation - Penn State - University Park, PA"
      expect(page).to_not have_content "Bob's Other Presentation - -"
    end
  end

  feature "the profile performances edit page" do
    before do
      authenticate_as(user)
      visit edit_profile_performances_path
    end

    it_behaves_like "a profile management page"

    it "shows the correct heading content" do
      expect(page).to have_content "Performances for Bob Testuser"
    end

    it "shows descriptions of the user's visible performances" do
      expect(page).to have_content "Bob's Performance - University Park, PA - 2000-01-01"
      expect(page).to_not have_content "Bob's Other Performance - -"
    end
  end
end
