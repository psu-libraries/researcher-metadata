require 'integration/integration_spec_helper'
require 'integration/profiles/shared_examples_for_profile_management_page'

describe "editing profile preferences" do
  let!(:user) { create :user,
                       webaccess_id: 'abc123',
                       first_name: 'Bob',
                       last_name: 'Testuser',
                       ai_bio: "Bob's bio info",
                       show_all_publications: true,
                       orcid_identifier: orcid_id,
                       orcid_access_token: orcid_token }
  let!(:other_user) { create :user, webaccess_id: 'xyz789'}

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
  let(:orcid_token) { nil }

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

          it "does display an ORCID call to action" do
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
        expect(page).to have_content "Manage Profile Publications"
      end

      context "when the user has publications" do
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
        let!(:pub_5) { create :publication,
                              title: "Bob's Non-Open Access Publication",
                              visible: true }
        let!(:pub_6) { create :publication,
                              title: "Bob's Pending ScholarSphere Publication",
                              visible: true }
        let!(:auth_1) { create :authorship, publication: pub_1, user: user, visible_in_profile: false }
        let!(:auth_2) { create :authorship, publication: pub_2, user: user, visible_in_profile: false }
        let!(:auth_3) { create :authorship, publication: pub_3, user: user, visible_in_profile: false }
        let!(:auth_4) { create :authorship, publication: pub_4, user: user, visible_in_profile: false }
        let!(:auth_5) { create :authorship, publication: pub_5, user: user, visible_in_profile: false }
        let!(:auth_6) { create :authorship,
                                publication: pub_6,
                                user: user,
                                visible_in_profile: false,
                                scholarsphere_uploaded_at: Time.current }
        let!(:waiver) { create :internal_publication_waiver, authorship: auth_5 }

        before { visit edit_profile_publications_path }

        it "shows descriptions of the user's visible publications" do
          expect(page).to have_content "Bob's Publication, The Journal, 2007"
          expect(page).to have_link "Bob's Publication", href: edit_open_access_publication_path(pub_1)
          expect(page).to_not have_content "Bob's Other Publication"
          expect(page).to have_content "Bob's Open Access Publication"
          expect(page).not_to have_link "Bob's Open Access Publication"
          expect(page).to have_content "Bob's Other Open Access Publication"
          expect(page).not_to have_link "Bob's Other Open Access Publication"
          expect(page).to have_content "Bob's Non-Open Access Publication"
          expect(page).not_to have_link "Bob's Non-Open Access Publication"
          expect(page).to have_content "Bob's Pending ScholarSphere Publication"
          expect(page).not_to have_link "Bob's Pending ScholarSphere Publication"
        end

        it "shows an icon to indicate when we don't have open access information for a publication" do
          within "tr#authorship_#{auth_1.id}" do
            expect(page).to have_css '.fa-question'
          end
        end

        it "shows an icon to indicate when we have an open access URL for a publication" do
          within "tr#authorship_#{auth_3.id}" do
            expect(page).to have_css '.fa-unlock-alt'
          end

          within "tr#authorship_#{auth_4.id}" do
            expect(page).to have_css '.fa-unlock-alt'
          end
        end

        it "shows an icon to indicate when open access obligations have been waived for a publication" do
          within "tr#authorship_#{auth_5.id}" do
            expect(page).to have_css '.fa-lock'
          end
        end

        it "shows an icon to indicate when a publication is being added to ScholarSphere" do
          within "tr#authorship_#{auth_6.id}" do
            expect(page).to have_css '.fa-hourglass-half'
          end
        end

        it "shows a link to submit a waiver for a publication that is outside of the system" do
          expect(page).to have_link "waiver form", href: new_external_publication_waiver_path
        end

        it "does not show the empty list message" do
          expect(page).not_to have_content "There are currently no publications to show for your profile."
        end
      end

      context "when the user has no publications" do
        it "shows a message about the empty list" do
          expect(page).to have_content "There are currently no publications to show for your profile."
        end
      end

      context "when the user has no external publication waivers" do
        it "does not show the waiver list" do
          expect(page).not_to have_content "Open Access Waivers"
        end
      end

      context "when the user has external publication waivers" do
        let!(:waiver1) { create :external_publication_waiver,
                                user: user,
                                publication_title: "Waived Publication",
                                journal_title: "Example Journal" }
        let!(:waiver2) { create :external_publication_waiver,
                                user: user,
                                publication_title: "Another Waived Publication",
                                journal_title: "Other Journal" }

        before { visit edit_profile_publications_path }
        it "shows the list of waivers" do
          expect(page).to have_content "Open Access Waivers"

          within "#external_publication_waiver_#{waiver1.id}" do
            expect(page).to have_content "Waived Publication"
            expect(page).to have_content "Example Journal"
          end

          within "#external_publication_waiver_#{waiver2.id}" do
            expect(page).to have_content "Another Waived Publication"
            expect(page).to have_content "Other Journal"
          end
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
        expect(page).to have_content "Manage Profile Presentations"
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
        expect(page).to have_content "Manage Profile Performances"
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

  feature "the profile bio page" do
    context "when the user is signed in" do
      before do
        authenticate_as(user)
        visit profile_bio_path
      end

      it_behaves_like "a profile management page"

      it "shows the correct heading content" do
        expect(page).to have_content "Profile Bio"
      end

      it "shows bio information for the user" do
        expect(page).to have_content "Bob Testuser"
      end

      context "when the user doesn't belong to an organization" do
        it "does not show organization information" do
          expect(page).not_to have_content "Organization"
        end
      end

      context "when the user belongs to an organization" do
        let(:org) { create :organization, name: "Biology" }
        let(:employment_button_text) { "Add to my ORCID Record" }
        let(:connect_orcid_button_text) { "Register or Connect your ORCID iD" }
        let(:orcid_employment_id) { nil }
        before do
          create :user_organization_membership,
                 user: user,
                 organization: org,
                 position_title: "Professor",
                 started_on: Date.new(2010, 1, 1),
                 ended_on: Date.new(2015, 12, 31),
                 pure_identifier: '123456789',
                 orcid_resource_identifier: orcid_employment_id

          visit profile_bio_path
        end
        it "shows organization information" do
          expect(page).to have_content "Organization"
          expect(page).to have_content "Biology"
          expect(page).to have_content "Professor"
          expect(page).to have_content "2010-01-01"
          expect(page).to have_content "2015-12-31"
        end

        context "when the user does not have an ORCID iD" do
          it "does not show a button to connect to the user's ORCID record" do
            expect(page).not_to have_button connect_orcid_button_text
          end

          it "does not show a button to add an employment to their ORCID record" do
            expect(page).not_to have_button employment_button_text
          end
        end
        context "when the user has an ORCiD" do
          let(:orcid_id) { "https://orcid.org/0000-0000-1234-5678" }
          context "when the user has an ORCID access token" do
            let(:orcid_token) { "abc123" }
            it "does not show a button to connect to the user's ORCID record" do
              expect(page).not_to have_button connect_orcid_button_text
            end

            it "shows the user's ORCID iD" do
              expect(page).to have_link "https://orcid.org/0000-0000-1234-5678",
                                        href: "https://orcid.org/0000-0000-1234-5678"
            end

            context "when the user's primary organization membership has been added to their ORCID record" do
              let(:orcid_employment_id) { "an identifier" }

              it "does not show a button to add the employment to their ORCID record" do
                expect(page).not_to have_button employment_button_text
              end

              it "tells the user that the information has been added" do
                expect(page).to have_content "information has been added to your ORCID record"
              end
            end

            context "when the user's primary organization membership has not been added to their ORCID record" do
              it "shows a button to add the employment to their ORCID record" do
                expect(page).to have_button employment_button_text
              end
            end
          end

          context "when the user does not have an ORCID access token" do
            it "shows the user's ORCID iD" do
              expect(page).to have_link "https://orcid.org/0000-0000-1234-5678",
                                        href: "https://orcid.org/0000-0000-1234-5678"
            end
            
            it "shows a button to connect to the user's ORCID record" do
              expect(page).to have_button connect_orcid_button_text
            end

            it "does not show a button to add the employment to their ORCID record" do
              expect(page).not_to have_button employment_button_text
            end
          end
        end
      end
    end

    context "when the user is not signed in" do
      before { visit profile_bio_path }

      it "does not allow the user to visit the page" do
        expect(page.current_path).not_to eq profile_bio_path
      end
    end
  end

  describe "the path /profile" do
    before do
      authenticate_as(user)
      visit 'profile'
    end

    it "redirects to the profile publications edit page" do
      expect(page.current_path).to eq edit_profile_publications_path
    end
  end
end
