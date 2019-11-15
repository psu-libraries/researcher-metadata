require 'integration/integration_spec_helper'
require 'integration/profiles/shared_examples_for_profile_management_page'

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
  let!(:pub_3) { create :publication,
                        title: "Bob's Open Access Publication",
                        visible: true,
                        open_access_url: "https://example.org/pubs/1" }
  let!(:pub_4) { create :publication,
                        title: "Bob's Other Open Access Publication",
                        visible: true,
                        user_submitted_open_access_url: "https://example.org/pubs/2" }
  let!(:auth_1) { create :authorship, publication: pub_1, user: user, visible_in_profile: false }
  let!(:auth_2) { create :authorship, publication: pub_2, user: user, visible_in_profile: false }
  let!(:auth_3) { create :authorship, publication: pub_3, user: user, visible_in_profile: false }
  let!(:auth_4) { create :authorship, publication: pub_4, user: user, visible_in_profile: false }
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

  feature "the profile publications edit page" do
    context "when the user is signed in" do
      before do
        authenticate_as(user)
        visit edit_profile_publications_path
      end

      it_behaves_like "a profile management page"

      it "shows the correct heading content" do
        expect(page).to have_content "Publications for Bob Testuser"
      end

      it "shows descriptions of the user's visible publications" do
        expect(page).to have_content "Bob's Publication, The Journal, 2007"
        expect(page).not_to have_link "Bob's Publication"
        expect(page).to_not have_content "Bob's Other Publication"
        expect(page).to have_link "Bob's Open Access Publication", href: 'https://example.org/pubs/1'
        expect(page).to have_link "Bob's Other Open Access Publication", href: 'https://example.org/pubs/2'
      end

      it "shows links to add open access info for non-open access publications" do
        within "tr#authorship_#{auth_1.id}" do
          expect(page).to have_css '.fa-unlock-alt'
          expect(page).to have_link '', href: edit_open_access_publication_path(pub_1)
        end
      end

      it "does not show links to add open access info for open access publications" do
        within "tr#authorship_#{auth_3.id}" do
          expect(page).not_to have_css '.fa-unlock-alt'
          expect(page).not_to have_link '', href: edit_open_access_publication_path(pub_3)
        end

        within "tr#authorship_#{auth_4.id}" do
          expect(page).not_to have_css '.fa-unlock-alt'
          expect(page).not_to have_link '', href: edit_open_access_publication_path(pub_4)
        end
      end
    end
    
    context "when the user is not signed in" do
      before { visit edit_profile_publications_path }

      it "does not allow the user to visit the page" do
        expect(page.current_path).not_to eq edit_profile_publications_path
      end
    end
  end

  feature "the profile presentations edit page" do
    context "when the user is signed in" do
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

    context "when the user is not signed in" do
      before { visit edit_profile_presentations_path }

      it "does not allow the user to visit the page" do
        expect(page.current_path).not_to eq edit_profile_presentations_path
      end
    end
  end

  feature "the profile performances edit page" do
    context "when the user is signed in" do
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

    context "when the user is not signed in" do
      before { visit edit_profile_performances_path }

      it "does not allow the user to visit the page" do
        expect(page.current_path).not_to eq edit_profile_performances_path
      end
    end
  end
end
