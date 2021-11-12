# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/profiles/shared_examples_for_profile_management_page'

describe 'claiming authorship of a publication' do
  let(:user) { create :user, webaccess_id: 'abc123', first_name: 'Test', last_name: 'Claimer' }
  let!(:pub1) { create :publication, title: 'Researcher Metadata Database Test Publication' }
  let(:pub2) { create :publication,
                      title: 'Another Researcher Metadata Database Test Publication',
                      doi: 'https://doi.org/10.000/some-doi-457472486',
                      journal: journal,
                      volume: '101',
                      issue: '102',
                      page_range: '103',
                      published_on: Date.new(2021, 1, 1) }
  let(:pub3) { create :publication, title: 'Non-matching Pub' }
  let(:pub2_author1) { create :user, first_name: 'Paula', last_name: 'Paperauthor' }
  let(:pub2_author2) { create :user, first_name: 'Robert', last_name: 'Researcher' }
  let(:journal) { create :journal, title: 'Test Journal' }

  before do
    create :contributor_name, first_name: 'Susanna', last_name: 'scientist', publication: pub1
    create :authorship, publication: pub2, user: pub2_author1
    create :authorship, publication: pub2, user: pub2_author2
  end

  context 'when the user is signed in' do
    before { authenticate_as(user) }

    describe 'visiting the page to search for publications' do
      before { visit publications_path }

      it_behaves_like 'a profile management page'

      describe 'submitting the form to search for publications by title' do
        before { do_title_search }

        it 'shows a list of matching publications' do
          within "#publication_#{pub1.id}" do
            expect(page).to have_content 'Researcher Metadata Database Test Publication'
          end

          within "#publication_#{pub2.id}" do
            expect(page).to have_content 'Another Researcher Metadata Database Test Publication'
          end

          expect(page).not_to have_content pub3.title
        end

        context 'when matching publications are not visible' do
          let!(:pub1) { create :publication, title: 'Researcher Metadata Database Test Publication', visible: false }
          let!(:pub2) { create :publication, title: 'Another Researcher Metadata Database Test Publication', visible: false }

          before { do_title_search }

          it 'does not show the matching publications' do
            expect(page).not_to have_content 'Researcher Metadata Database Test Publication'
          end
        end

        context 'when matching publications are not journal articles' do
          let!(:pub1) { create :publication, title: 'Researcher Metadata Database Test Publication', publication_type: 'Book' }
          let!(:pub2) { create :publication, title: 'Another Researcher Metadata Database Test Publication', publication_type: 'Book' }

          before { do_title_search }

          it 'does not show the matching publications' do
            expect(page).not_to have_content 'Researcher Metadata Database Test Publication'
          end
        end

        context 'when the user is already a known author of matching publications' do
          before do
            create :authorship, publication: pub1, user: user
            create :authorship, publication: pub2, user: user
            do_title_search
          end

          it 'does not show the matching publications' do
            expect(page).not_to have_content 'Researcher Metadata Database Test Publication'
          end
        end
      end

      describe 'submitting the form to search for publications by author name' do
        before { do_name_search }

        it 'shows a list of matching publications' do
          expect(page).to have_content 'Matching Publications'
          within "#publication_#{pub1.id}" do
            expect(page).to have_content 'Researcher Metadata Database Test Publication'
          end

          expect(page).not_to have_content 'Another Researcher Metadata Database Test Publication'
          expect(page).not_to have_content pub3.title
        end
      end

      describe 'submitting the form without any search criteria' do
        before do
          visit publications_path
          click_on 'Search'
        end

        it 'does not show any publications' do
          expect(page).not_to have_content 'Test Publication'
          expect(page).not_to have_content pub3.title
          expect(page).not_to have_content 'Matching Publications'
        end
      end

      describe 'navigating to see the details about a found publication' do
        before do
          do_title_search

          within "#publication_#{pub2.id}" do
            click_on 'View Details'
          end
        end

        it 'loads the correct page' do
          expect(page).to have_current_path publication_path(pub2), ignore_query: true
        end

        it_behaves_like 'a profile management page'

        it 'shows details about the publication' do
          expect(page).to have_content 'Another Researcher Metadata Database Test Publication'
          expect(page).to have_content 'Test Journal'
          expect(page).to have_content 'Paula Paperauthor'
          expect(page).to have_content 'Robert Researcher'
          expect(page).to have_content 'https://doi.org/10.000/some-doi-457472486'
          expect(page).to have_content '101'
          expect(page).to have_content '102'
          expect(page).to have_content '103'
          expect(page).to have_content '2021'
        end

        it 'shows a link back to the search list' do
          expect(page).to have_link 'Back to list'
        end

        describe 'submitting the form to claim the publication' do
          let(:new_authorship) { user.authorships.first }

          before do
            fill_in 'Author number', with: 2
            click_button 'Claim Publication'
          end

          it 'sends a notification of the claim to the RMD admins' do
            open_email('rmd-admin@psu.edu')
            expect(current_email.body).to match(/Test Claimer/)
          end

          it 'returns the user to page for managing their profile publications' do
            expect(page).to have_current_path edit_profile_publications_path, ignore_query: true
          end

          it 'shows the claimed publication in the list' do
            within "#authorship_row_#{new_authorship.id}" do
              expect(page).to have_content 'Another Researcher Metadata Database Test Publication'
            end
          end

          it 'indicates that the authorship for the claimed publication is unconfirmed' do
            within "#authorship_row_#{new_authorship.id}" do
              expect(page).to have_css '.fa-minus'
            end
          end

          it "does not show a button to add the claimed publication to the user's ORCiD record" do
            within "#authorship_row_#{new_authorship.id}" do
              expect(page).not_to have_css '.orcid-button'
            end
          end

          it 'does not show a link to edit open access information for the claimed publication' do
            expect(page).not_to have_link 'Another Researcher Metadata Database Test Publication'
          end
        end
      end
    end
  end
end

def do_title_search
  visit publications_path
  fill_in 'Title', with: 'metadata database'
  click_on 'Search'
end

def do_name_search
  visit publications_path
  fill_in 'First name', with: 's'
  fill_in 'Last name', with: 'scientist'
  click_on 'Search'
end
