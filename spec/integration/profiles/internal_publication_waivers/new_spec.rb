# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/profiles/shared_examples_for_profile_management_page'

describe 'visiting the page to submit an open access waiver for a publication' do
  let(:user) { create(:user,
                      webaccess_id: 'test123',
                      first_name: 'Test',
                      last_name: 'User') }
  let(:pub) { create(:publication,
                     title: 'Test Publication',
                     abstract: 'This is the abstract.',
                     doi: 'https://doi.org/10.000/1234',
                     journal_title: 'A Prestegious Journal',
                     issue: '583',
                     volume: '971',
                     page_range: '478-483',
                     published_on: Date.new(2019, 1, 1)) }
  let(:other_pub) { create(:publication) }
  let(:oa_pub) { create(:publication, open_access_locations: [build(:open_access_location, :open_access_button, url: 'a URL')]) }
  let(:uoa_pub) { create(:publication, open_access_locations: [build(:open_access_location, :user, url: 'user URL')]) }
  let!(:auth) { create(:authorship, user: user, publication: pub) }

  before do
    create(:authorship, user: user, publication: oa_pub)
    create(:authorship, user: user, publication: uoa_pub)
  end

  context 'when the user is not signed in' do
    before { visit new_internal_publication_waiver_path(pub) }

    it 'does not allow them to visit the page' do
      expect(page).not_to have_current_path new_internal_publication_waiver_path(pub), ignore_query: true
    end
  end

  context 'when the user is signed in' do
    before { authenticate_as(user) }

    context 'when requesting a publication that belongs to the user' do
      before { visit new_internal_publication_waiver_path(pub) }

      it_behaves_like 'a profile management page'

      it 'shows the correct heading' do
        expect(page).to have_content 'Open Access Waiver'
      end

      it 'shows the title of the publication' do
        expect(page.find_field('Title').value).to eq 'Test Publication'
      end

      it 'shows the abstract of the publication' do
        expect(page.find_field('Abstract').value).to eq 'This is the abstract.'
      end

      it "shows the publication's DOI" do
        expect(page.find_field('Digital Object Identifier (DOI)').value).to eq 'https://doi.org/10.000/1234'
      end

      it "shows the publication's journal" do
        expect(page.find_field('Journal').value).to eq 'A Prestegious Journal'
      end

      it 'shows a link to the ScholarSphere website' do
        expect(page).to have_link 'ScholarSphere', href: 'https://scholarsphere.psu.edu/'
      end

      describe 'submitting the waiver' do
        before do
          fill_in 'Reason for waiver', with: 'Because I said so.'
          click_button 'Submit'
        end

        it 'saves the waiver' do
          waiver = auth.waiver
          expect(waiver).not_to be_nil
          expect(waiver.reason_for_waiver).to eq 'Because I said so.'
        end

        it 'sends a confirmation email to the user' do
          open_email('test123@psu.edu')
          expect(current_email).not_to be_nil
          expect(current_email.subject).to match(/PSU Open Access Policy Waiver for Requested Article/i)
          expect(current_email.body).to match(/Test A Person/)
          expect(current_email.body).to match(/Test Publication/)
          expect(current_email.body).to match(/A Prestegious Journal/)
        end

        it 'redirects to the publication list' do
          expect(page).to have_current_path edit_profile_publications_path, ignore_query: true
        end

        it 'shows a success message' do
          expect(page).to have_content I18n.t('profile.internal_publication_waivers.create.success',
                                              title: 'Test Publication')
        end
      end
    end

    context 'when requesting a publication that does not belong to the user' do
      it 'returns 404' do
        visit new_internal_publication_waiver_path(other_pub)
        expect(page.status_code).to eq 404
      end
    end
  end
end
