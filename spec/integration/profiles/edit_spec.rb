# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/profiles/shared_examples_for_profile_management_page'

describe 'editing profile preferences' do
  let!(:user) { create(:user,
                       webaccess_id: 'abc123',
                       first_name: 'Bob',
                       middle_name: '',
                       last_name: 'Testuser',
                       ai_bio: "Bob's bio info",
                       show_all_publications: true,
                       orcid_identifier: orcid_id,
                       orcid_access_token: orcid_token) }
  let!(:other_user) { create(:user, webaccess_id: 'xyz789') }

  let!(:pres1) { create(:presentation,
                        title: "Bob's Presentation",
                        organization: 'Penn State',
                        location: 'University Park, PA',
                        visible: true) }
  let!(:pres2) { create(:presentation,
                        title: "Bob's Other Presentation",
                        visible: false) }
  let!(:cont_1) { create(:presentation_contribution,
                         presentation: pres1,
                         user: user,
                         visible_in_profile: false) }
  let!(:cont_2) { create(:presentation_contribution,
                         presentation: pres2,
                         user: user,
                         visible_in_profile: false) }
  let!(:perf_1) { create(:performance,
                         title: "Bob's Performance",
                         location: 'University Park, PA',
                         start_on: Date.new(2000, 1, 1),
                         visible: true) }
  let!(:perf_2) { create(:performance,
                         title: "Bob's Other Performance",
                         visible: true) }
  let!(:up_1) { create(:user_performance,
                       performance: perf_1,
                       user: user) }
  let!(:up_2) { create(:user_performance,
                       performance: perf_2,
                       user: user) }
  let(:orcid_id) { nil }
  let(:orcid_token) { nil }

  describe 'the manage profile link', :js, type: :feature do
    describe 'visiting the profile page for a given user' do
      context 'when not logged in' do
        before do
          person = instance_spy(PsuIdentity::SearchService::Person)
          allow_any_instance_of(PsuIdentity::SearchService::Client).to receive(:userid).with(user.webaccess_id).and_return(person) # rubocop:todo RSpec/AnyInstance

          visit profile_path(webaccess_id: user.webaccess_id)
        end

        it 'does not display a link to manage the profile' do
          expect(page).to have_no_link 'Manage my profile'
        end
      end

      context 'when logged in as that user' do
        before do
          authenticate_as(user)
          visit profile_path(webaccess_id: user.webaccess_id)
        end

        it 'displays a link to manage the profile' do
          expect(page).to have_link 'Manage my profile', href: profile_bio_path
        end
      end

      context 'when logged in as a different user' do
        before do
          person = instance_spy(PsuIdentity::SearchService::Person)
          allow_any_instance_of(PsuIdentity::SearchService::Client).to receive(:userid).with('abc123').and_return(person) # rubocop:todo RSpec/AnyInstance

          authenticate_as(other_user)
          visit profile_path(webaccess_id: user.webaccess_id)
        end

        it 'does not display a link to manage the profile' do
          expect(page).to have_no_link 'Manage my profile'
        end
      end

      context 'when logged in as an admin' do
        before do
          person = instance_spy(PsuIdentity::SearchService::Person)
          allow_any_instance_of(PsuIdentity::SearchService::Client).to receive(:userid).with(user.webaccess_id).and_return(person) # rubocop:todo RSpec/AnyInstance
          allow(person).to receive(:as_json).and_return({ 'data' => {} })

          authenticate_admin_user
          visit profile_path(webaccess_id: user.webaccess_id)
        end

        it 'allows the admin to become and unbecome the user in the profile' do
          click_button('Become this user')
          expect(page).to have_content("You are acting on behalf of #{user.webaccess_id}")
          expect(page).to have_button("Unbecome #{user.webaccess_id}")
          click_link('Manage my profile')
          expect(page).to have_button("Stop being #{user.webaccess_id}")
          click_button("Stop being #{user.webaccess_id}")
          click_button('Become this user')
          click_button("Unbecome #{user.webaccess_id}")
        end
      end

      context 'when logged in as a deputy of the user' do
        let(:deputy) { create(:user) }

        before do
          person = instance_spy(PsuIdentity::SearchService::Person)
          allow_any_instance_of(PsuIdentity::SearchService::Client).to receive(:userid).with(user.webaccess_id).and_return(person) # rubocop:todo RSpec/AnyInstance
          allow(person).to receive(:as_json).and_return({ 'data' => {} })

          create(:deputy_assignment, primary: user, deputy: deputy)
          authenticate_as(deputy)
          visit profile_path(webaccess_id: user.webaccess_id)
        end

        it 'allows the deputy to become and unbecome the user in the profile' do
          click_button('Become this user')
          expect(page).to have_content('You are acting on behalf of abc123')
          expect(page).to have_button('Unbecome abc123')
          click_link('Manage my profile')
          expect(page).to have_button('Stop being abc123')
          click_button('Stop being abc123')
          click_button('Become this user')
          click_button('Unbecome abc123')
        end
      end
    end
  end

  describe 'the ORCID link', type: :feature do
    describe 'visiting the profile page for a given user' do
      context 'when not logged in' do
        before do
          person = instance_spy(PsuIdentity::SearchService::Person)
          allow_any_instance_of(PsuIdentity::SearchService::Client).to receive(:userid).with(user.webaccess_id).and_return(person) # rubocop:todo RSpec/AnyInstance

          visit profile_path(webaccess_id: user.webaccess_id)
        end

        context 'when the user has no ORCID ID' do
          it 'does not display an ORCID ID link' do
            expect(page).to have_no_link 'ORCID iD'
          end

          it 'does not display an ORCID call to action' do
            expect(page).to have_no_link 'Link my ORCID ID'
          end
        end

        context 'when the user has an ORCID ID' do
          let(:orcid_id) { 'https://orcid.org/my-orcid-id' }

          it 'displays an ORCID ID link' do
            expect(page).to have_link 'ORCID iD', href: 'https://orcid.org/my-orcid-id'
          end

          it 'does not display an ORCID call to action' do
            expect(page).to have_no_link 'Link my ORCID ID'
          end
        end
      end

      context 'when logged in as that user' do
        before do
          authenticate_as(user)
          visit profile_path(webaccess_id: user.webaccess_id)
        end

        context 'when the user has no ORCID ID' do
          it 'does not display an ORCID ID link' do
            expect(page).to have_no_link 'ORCID iD'
          end

          it 'does display an ORCID call to action' do
            expect(page).to have_link 'Link my ORCID ID', href: 'https://guides.libraries.psu.edu/orcid'
          end
        end

        context 'when the user has an ORCID ID' do
          let(:orcid_id) { 'https://orcid.org/my-orcid-id' }

          it 'displays an ORCID ID link' do
            expect(page).to have_link 'ORCID iD', href: 'https://orcid.org/my-orcid-id'
          end

          it 'does not display an ORCID call to action' do
            expect(page).to have_no_link 'Link my ORCID ID'
          end
        end
      end

      context 'when logged in as a different user' do
        before do
          person = instance_spy(PsuIdentity::SearchService::Person)
          allow_any_instance_of(PsuIdentity::SearchService::Client).to receive(:userid).with(user.webaccess_id).and_return(person) # rubocop:todo RSpec/AnyInstance
          allow(person).to receive(:as_json).and_return({ 'data' => {} })

          authenticate_as(other_user)
          visit profile_path(webaccess_id: user.webaccess_id)
        end

        context 'when the user has no ORCID ID' do
          it 'does not display an ORCID ID link' do
            expect(page).to have_no_link 'ORCID iD'
          end

          it 'does not display an ORCID call to action' do
            expect(page).to have_no_link 'Link my ORCID ID'
          end
        end

        context 'when the user has an ORCID ID' do
          let(:orcid_id) { 'https://orcid.org/my-orcid-id' }

          it 'displays an ORCID ID link' do
            expect(page).to have_link 'ORCID iD', href: 'https://orcid.org/my-orcid-id'
          end

          it 'does not display an ORCID call to action' do
            expect(page).to have_no_link 'Link my ORCID ID'
          end
        end
      end
    end
  end

  describe 'the profile publications edit page' do
    context 'when the user is signed in' do
      before do
        authenticate_as(user)
        visit edit_profile_publications_path
      end

      it_behaves_like 'a profile management page'

      it 'shows the correct heading content' do
        expect(page).to have_content 'Manage Profile Publications'
      end

      it 'shows a link to search for publications' do
        expect(page).to have_link 'Search', href: publications_path
      end

      context 'when the user has publications' do
        let!(:pub_1) { create(:publication,
                              title: "Bob's Publication",
                              visible: true,
                              journal_title: 'The Journal',
                              published_on: Date.new(2007, 1, 1)) }
        let!(:pub_2) { create(:publication,
                              title: "Bob's Other Publication",
                              visible: false) }
        let!(:pub_3) { create(:publication,
                              title: "Bob's Open Access Publication",
                              visible: true,
                              open_access_locations: [build(:open_access_location,
                                                            source: Source::OPEN_ACCESS_BUTTON,
                                                            url: 'https://example.org/pubs/1')]) }
        let!(:pub_4) { create(:publication,
                              title: "Bob's Other Open Access Publication",
                              visible: true,
                              open_access_locations: [build(:open_access_location,
                                                            source: Source::OPEN_ACCESS_BUTTON,
                                                            url: 'https://example.org/pubs/2')]) }
        let!(:pub_5) { create(:publication,
                              title: "Bob's Non-Open Access Publication",
                              visible: true) }
        let!(:pub_6) { create(:publication,
                              title: "Bob's Pending Scholarsphere Publication",
                              visible: true) }
        let!(:pub_7) { create(:publication,
                              title: "Bob's In Press Publication",
                              status: 'In Press',
                              visible: true) }
        let!(:pub_8) { create(:publication,
                              title: "Bob's Uploaded to Activity Insight",
                              activity_insight_postprint_status: 'In Progress',
                              visible: true) }
        let!(:auth_1) { create(:authorship, publication: pub_1, user: user, visible_in_profile: false) }
        let!(:auth_2) { create(:authorship, publication: pub_2, user: user, visible_in_profile: false) }
        let!(:auth_3) { create(:authorship, publication: pub_3, user: user, visible_in_profile: false) }
        let!(:auth_4) { create(:authorship, publication: pub_4, user: user, visible_in_profile: false) }
        let!(:auth_5) { create(:authorship, publication: pub_5, user: user, visible_in_profile: false) }
        let!(:auth_6) { create(:authorship,
                               publication: pub_6,
                               user: user,
                               visible_in_profile: false) }
        let!(:auth_7) { create(:authorship, publication: pub_7, user: user, visible_in_profile: false) }
        let!(:auth_8) { create(:authorship, publication: pub_8, user: user, visible_in_profile: false) }
        let!(:swd) { create(:scholarsphere_work_deposit, authorship: auth_6, status: 'Pending') }
        let!(:waiver) { create(:internal_publication_waiver, authorship: auth_5) }

        before { visit edit_profile_publications_path }

        it "shows descriptions of the user's visible publications" do
          expect(page).to have_content "Bob's Publication, The Journal, 2007"
          expect(page).to have_link "Bob's Publication", href: edit_open_access_publication_path(pub_1)
          expect(page).to have_no_content "Bob's Other Publication"
          expect(page).to have_content "Bob's Open Access Publication"
          expect(page).to have_no_link "Bob's Open Access Publication"
          expect(page).to have_content "Bob's Other Open Access Publication"
          expect(page).to have_no_link "Bob's Other Open Access Publication"
          expect(page).to have_content "Bob's Non-Open Access Publication"
          expect(page).to have_no_link "Bob's Non-Open Access Publication"
          expect(page).to have_content "Bob's Pending Scholarsphere Publication"
          expect(page).to have_no_link "Bob's Pending Scholarsphere Publication"
          expect(page).to have_content "Bob's In Press Publication"
          expect(page).to have_no_link "Bob's In Press Publication"
          expect(page).to have_content "Bob's Uploaded to Activity Insight"
          expect(page).to have_no_link "Bob's Uploaded to Activity Insight"
        end

        it "shows an icon to indicate when we don't have open access information for a publication" do
          within "tr#authorship_row_#{auth_1.id}" do
            expect(page).to have_css '.fa-question'
          end
        end

        it 'shows an icon to indicate when we have an open access URL for a publication' do
          within "tr#authorship_row_#{auth_3.id}" do
            expect(page).to have_css '.fa-unlock-alt'
          end

          within "tr#authorship_row_#{auth_4.id}" do
            expect(page).to have_css '.fa-unlock-alt'
          end
        end

        it 'shows an icon to indicate when open access obligations have been waived for a publication' do
          within "tr#authorship_row_#{auth_5.id}" do
            expect(page).to have_css '.fa-lock'
          end
        end

        it 'shows an icon to indicate when a publication is being added to ScholarSphere' do
          within "tr#authorship_row_#{auth_6.id}" do
            expect(page).to have_css '.fa-hourglass-half'
          end
        end

        it "shows an icon to indicate when a publication is not 'Published' (still 'In Press')" do
          within "tr#authorship_row_#{auth_7.id}" do
            expect(page).to have_css '.fa-circle-o-notch'
          end
        end

        it 'shows an icon to indicate when a publication has been uploaded to Activity Insight' do
          within "tr#authorship_row_#{auth_8.id}" do
            expect(page).to have_css '.fa-upload'
          end
        end

        it 'shows a link to submit a waiver for a publication that is outside of the system' do
          expect(page).to have_link 'waiver form', href: new_external_publication_waiver_path
        end

        it 'does not show the empty list message' do
          expect(page).to have_no_content 'There are currently no publications to show for your profile.'
        end
      end

      context 'when the user has no publications' do
        it 'shows a message about the empty list' do
          expect(page).to have_content 'There are currently no publications to show for your profile.'
        end
      end

      context 'when the user has no external publication waivers' do
        it 'does not show the waiver list' do
          expect(page).to have_no_content 'Open Access Waivers'
        end
      end

      context 'when the user has external publication waivers' do
        let!(:waiver1) { create(:external_publication_waiver,
                                user: user,
                                publication_title: 'Waived Publication',
                                journal_title: 'Example Journal') }
        let!(:waiver2) { create(:external_publication_waiver,
                                user: user,
                                publication_title: 'Another Waived Publication',
                                journal_title: 'Other Journal') }

        before { visit edit_profile_publications_path }

        it 'shows the list of waivers' do
          expect(page).to have_content 'Open Access Waivers'

          within "#external_publication_waiver_#{waiver1.id}" do
            expect(page).to have_content 'Waived Publication'
            expect(page).to have_content 'Example Journal'
          end

          within "#external_publication_waiver_#{waiver2.id}" do
            expect(page).to have_content 'Another Waived Publication'
            expect(page).to have_content 'Other Journal'
          end
        end
      end
    end

    context 'when the user is not signed in' do
      before { visit edit_profile_publications_path }

      it 'does not allow the user to visit the page' do
        expect(page).to have_no_current_path edit_profile_publications_path, ignore_query: true
      end
    end
  end

  describe 'the profile other publications edit page' do
    context 'when the user is signed in' do
      before do
        authenticate_as(user)
        visit edit_profile_other_publications_path
      end

      it_behaves_like 'a profile management page'

      it 'shows the correct heading content' do
        expect(page).to have_content 'Manage Non-Article Profile Publications'
      end

      context 'when the user has other publications' do
        let!(:pub_1) { create(:publication,
                              publication_type: 'Chapter',
                              title: 'Title 1',
                              visible: true,
                              published_on: Date.new(2007, 1, 1)) }
        let!(:pub_2) { create(:publication,
                              publication_type: 'Chapter',
                              title: 'Title 2',
                              visible: false,
                              published_on: Date.new(2008, 1, 1)) }
        let!(:pub_3) { create(:publication,
                              publication_type: 'Letter',
                              title: 'Title 1',
                              visible: true,
                              journal_title: 'Journal 1',
                              published_on: Date.new(2008, 1, 1)) }
        let!(:auth_1) { create(:authorship, publication: pub_1, user: user) }
        let!(:auth_2) { create(:authorship, publication: pub_2, user: user) }
        let!(:auth_3) { create(:authorship, publication: pub_3, user: user) }

        before { visit edit_profile_other_publications_path }

        it "shows descriptions of the user's visible other publications" do
          expect(page).to have_content 'Chapter'
          expect(page).to have_content 'Title 1, 2007'
          expect(page).to have_no_content 'Title 2, 2008'
          expect(page).to have_content 'Letter'
          expect(page).to have_content 'Title 1, Journal 1, 2008'
        end
      end
    end

    context 'when the user is not signed in' do
      before { visit edit_profile_other_publications_path }

      it 'does not allow the user to visit the page' do
        expect(page).to have_no_current_path edit_profile_other_publications_path, ignore_query: true
      end
    end
  end

  describe 'the profile presentations edit page' do
    context 'when the user is signed in' do
      before do
        authenticate_as(user)
        visit edit_profile_presentations_path
      end

      it_behaves_like 'a profile management page'

      it 'shows the correct heading content' do
        expect(page).to have_content 'Manage Profile Presentations'
      end

      it "shows descriptions of the user's visible presentations" do
        expect(page).to have_content "Bob's Presentation - Penn State - University Park, PA"
        expect(page).to have_no_content "Bob's Other Presentation - -"
      end

      it 'allows user to deselect and select all presentations', :js, type: :feature do
        expect(page).to have_button 'Select All', wait: 1
        expect(page).to have_unchecked_field "presentation_contribution_#{cont_1.id}"
        expect(user.presentation_contributions.first.reload.visible_in_profile).to be false

        click_button 'Select All', wait: 1

        expect(page).to have_button 'Deselect All', wait: 1
        expect(page).to have_checked_field "presentation_contribution_#{cont_1.id}"

        expect(user.presentation_contributions.first.reload.visible_in_profile).to be true

        click_button 'Deselect All', wait: 1
        expect(page).to have_button 'Select All', wait: 1
        expect(page).to have_unchecked_field "presentation_contribution_#{cont_1.id}"
        expect(user.presentation_contributions.first.reload.visible_in_profile).to be false
      end
    end

    context 'when the user is not signed in' do
      before { visit edit_profile_presentations_path }

      it 'does not allow the user to visit the page' do
        expect(page).to have_no_current_path edit_profile_presentations_path, ignore_query: true
      end
    end
  end

  describe 'the profile performances edit page' do
    context 'when the user is signed in' do
      before do
        authenticate_as(user)
        visit edit_profile_performances_path
      end

      it_behaves_like 'a profile management page'

      it 'shows the correct heading content' do
        expect(page).to have_content 'Manage Profile Performances'
      end

      it "shows descriptions of the user's visible performances" do
        expect(page).to have_content "Bob's Performance - University Park, PA - 2000-01-01"
        expect(page).to have_no_content "Bob's Other Performance - -"
      end
    end

    context 'when the user is not signed in' do
      before { visit edit_profile_performances_path }

      it 'does not allow the user to visit the page' do
        expect(page).to have_no_current_path edit_profile_performances_path, ignore_query: true
      end
    end
  end

  describe 'the profile bio page' do
    context 'when the user is signed in' do
      before do
        authenticate_as(user)
        visit profile_bio_path
      end

      it_behaves_like 'a profile management page'

      it 'shows the correct heading content' do
        expect(page).to have_content 'Profile Bio'
      end

      it 'shows bio information for the user' do
        expect(page).to have_content 'Test A Person'
      end

      context "when the user doesn't belong to an organization" do
        it 'does not show organization information' do
          expect(page).to have_no_content 'Organizations'
        end
      end

      context 'when the user belongs to organizations' do
        let(:org1) { create(:organization, name: 'Biology') }
        let(:org2) { create(:organization, name: 'Life Sciences Institute') }
        let(:employment_button_text) { 'Add to my ORCID Record' }
        let(:connect_orcid_button_text) { 'Connect your ORCID iD' }
        let(:orcid_employment_id) { nil }

        let!(:mem1) {
          create(:user_organization_membership,
                 user: user,
                 organization: org1,
                 position_title: 'Professor',
                 started_on: Date.new(2010, 1, 1),
                 ended_on: Date.new(2015, 12, 31),
                 import_source: 'Pure',
                 source_identifier: '123456789',
                 orcid_resource_identifier: orcid_employment_id)
        }

        let!(:mem2) {
          create(:user_organization_membership,
                 user: user,
                 organization: org2,
                 position_title: 'Director',
                 started_on: Date.new(2012, 1, 1),
                 ended_on: Date.new(2015, 12, 31))
        }

        before { visit profile_bio_path }

        it 'shows information for each organization' do
          within "#organization_membership_#{mem1.id}" do
            expect(page).to have_content 'Biology'
            expect(page).to have_content 'Professor'
            expect(page).to have_content '2010-01-01'
            expect(page).to have_content '2015-12-31'
          end

          within "#organization_membership_#{mem2.id}" do
            expect(page).to have_content 'Life Sciences Institute'
            expect(page).to have_content 'Director'
            expect(page).to have_content '2012-01-01'
            expect(page).to have_content '2015-12-31'
          end
        end

        context 'when the user does not have an ORCID iD' do
          it "does not show a button to connect to the user's ORCID record" do
            expect(page).to have_no_button connect_orcid_button_text
          end

          it 'does not show a button to add an employment to their ORCID record' do
            expect(page).to have_no_button employment_button_text
          end
        end

        context 'when the user has an ORCiD' do
          let(:orcid_id) { 'https://orcid.org/0000-0000-1234-5678' }

          context 'when the user has an ORCID access token' do
            let(:orcid_token) { 'abc123' }

            it "does not show a button to connect to the user's ORCID record" do
              expect(page).to have_no_button connect_orcid_button_text
            end

            it "shows the user's ORCID iD" do
              expect(page).to have_link 'https://orcid.org/0000-0000-1234-5678',
                                        href: 'https://orcid.org/0000-0000-1234-5678'
            end

            context 'when the user has added an organization membership to their ORCID record' do
              let(:orcid_employment_id) { 'an identifier' }

              it 'does not show a button to add that employment to their ORCID record' do
                within "#organization_membership_#{mem1.id}" do
                  expect(page).to have_no_button employment_button_text
                end
              end

              it 'tells the user that the information has been added' do
                within "#organization_membership_#{mem1.id}" do
                  expect(page).to have_content 'information has been added to your ORCID record'
                end
              end
            end

            context 'when the user has not added an organization membership to their ORCID record' do
              it 'shows a button to add the employment to their ORCID record' do
                within "#organization_membership_#{mem1.id}" do
                  expect(page).to have_button employment_button_text
                end
              end
            end
          end

          context 'when the user does not have an ORCID access token' do
            it "shows the user's ORCID iD" do
              expect(page).to have_link 'https://orcid.org/0000-0000-1234-5678',
                                        href: 'https://orcid.org/0000-0000-1234-5678'
            end

            it "shows a button to connect to the user's ORCID record" do
              expect(page).to have_button connect_orcid_button_text
            end

            it 'does not show a button to add the employment to their ORCID record' do
              expect(page).to have_no_button employment_button_text
            end
          end
        end
      end

      context 'when the user has education history items', :js do
        let!(:edu1) { create(:education_history_item,
                             user: user,
                             institution: 'University A',
                             degree: 'PhD',
                             emphasis_or_major: 'Biology',
                             end_year: 2004) }
        let!(:edu2) { create(:education_history_item,
                             visible_in_profile: false,
                             user: user,
                             institution: 'University B',
                             degree: 'MS',
                             emphasis_or_major: 'Computer Science',
                             end_year: 2000) }

        before { visit profile_bio_path }

        it 'shows the education history items' do
          expect(page).to have_content 'Education History'
          expect(page).to have_content 'University A'
          expect(page).to have_content 'PhD'
          expect(page).to have_content 'Biology'
          expect(page).to have_content '2004'
          expect(page).to have_content 'University B'
          expect(page).to have_content 'MS'
          expect(page).to have_content 'Computer Science'
          expect(page).to have_content '2000'
        end

        it 'allows toggling the visible_in_profile checkbox' do
          uncheck "education_history_item_#{edu1.id}"
          sleep 0.25
          expect(edu1.reload.visible_in_profile).to be false

          check "education_history_item_#{edu2.id}"
          sleep 0.25
          expect(edu2.reload.visible_in_profile).to be true
        end
      end

      context 'when the user has no education history items' do
        it 'does not show the education history section' do
          expect(page).to have_no_content 'Education History'
        end
      end
    end

    context 'when the user is not signed in' do
      before { visit profile_bio_path }

      it 'does not allow the user to visit the page' do
        expect(page).to have_no_current_path profile_bio_path, ignore_query: true
      end
    end
  end

  describe 'the path /profile' do
    before do
      authenticate_as(user)
      visit 'profile'
    end

    it 'redirects to the profile publications edit page' do
      expect(page).to have_current_path edit_profile_publications_path, ignore_query: true
    end
  end
end
