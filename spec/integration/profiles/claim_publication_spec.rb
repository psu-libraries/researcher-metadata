# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/profiles/shared_examples_for_profile_management_page'

describe 'claiming authorship of a publication' do
  let(:user) { create :user, webaccess_id: 'abc123' }
  let!(:pub1) { create :publication, title: 'Researcher Metadata Database Test Publication' }
  let!(:pub2) { create :publication, title: 'Another Researcher Metadata Database Test Publication' }

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
        end

        context 'when matching publications are not visible' do
          let!(:pub1) { create :publication, title: 'Researcher Metadata Database Test Publication', visible: false }
          let!(:pub2) { create :publication, title: 'Another Researcher Metadata Database Test Publication', visible: false }

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
    end
  end
end

def do_title_search
  visit publications_path
  fill_in 'Title', with: 'Researcher Metadata Database Test Publication'
  click_on 'Search'
end
