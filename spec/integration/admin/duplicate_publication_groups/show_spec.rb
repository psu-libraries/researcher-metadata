# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe 'Admin duplicate publication group detail page', type: :feature do
  let!(:pub1) { create(:publication,
                       title: 'Duplicate Publication',
                       secondary_title: 'subtitle1',
                       journal_title: 'journal1',
                       publisher_name: 'publisher1',
                       published_on: Date.new(2018, 8, 13),
                       status: 'Published',
                       volume: 'volume1',
                       issue: 'issue1',
                       edition: 'edition1',
                       page_range: 'pages1',
                       issn: 'issn1',
                       doi: 'https://doi.org/10.000/doi1',
                       publication_type: 'Trade Journal Article',
                       duplicate_group: pub1_group) }

  let!(:pub2) { create(:publication,
                       title: 'A duplicate publication',
                       secondary_title: 'subtitle2',
                       journal_title: 'journal2',
                       publisher_name: 'publisher2',
                       published_on: Date.new(2018, 8, 14),
                       status: 'Published',
                       volume: 'volume2',
                       issue: 'issue2',
                       edition: 'edition2',
                       page_range: 'pages2',
                       issn: 'issn2',
                       doi: 'https://doi.org/10.000/doi2',
                       publication_type: 'Academic Journal Article',
                       duplicate_group: pub2_group) }

  let!(:nd_pub1) { create(:publication) }
  let!(:nd_pub2) { create(:publication) }

  let(:pub1_group) { nil }
  let(:pub2_group) { nil }

  let(:group) { create(:duplicate_publication_group) }

  let(:user1) { create(:user, first_name: 'Test1', last_name: 'User1') }
  let(:user2) { create(:user, first_name: 'Test2', last_name: 'User2') }
  let(:user3) { create(:user, first_name: 'Test3', last_name: 'User3') }

  let!(:con1) { create(:contributor_name,
                       first_name: 'Test1',
                       last_name: 'Contributor1',
                       publication: pub1,
                       position: 2) }
  let!(:con2) { create(:contributor_name,
                       first_name: 'Test2',
                       last_name: 'Contributor2',
                       publication: pub1,
                       position: 1) }
  let!(:con3) { create(:contributor_name,
                       first_name: 'Test3',
                       last_name: 'Contributor3',
                       publication: pub2,
                       position: 1) }

  before do
    create(:authorship, publication: pub1, user: user1)
    create(:authorship, publication: pub2, user: user2)
    create(:authorship, publication: pub2, user: user3)

    create(:publication_import, publication: pub1, source: 'Pure', source_identifier: 'pure-abc123')
    create(:publication_import, publication: pub1, source: 'Pure', source_identifier: 'pure-xyz789')
    create(:publication_import, publication: pub2, source: 'Activity Insight', source_identifier: 'ai-abc123')
    create(:publication_import, publication: pub2, source: 'Activity Insight', source_identifier: 'ai-xyz789')

    create(:non_duplicate_publication_group, publications: [pub1, nd_pub1, nd_pub2])
  end

  context 'when the current user is an admin' do
    before { authenticate_admin_user }

    context 'when the group has more than one publication' do
      let(:pub1_group) { group }
      let(:pub2_group) { group }

      describe 'the page content', :js do
        before { visit rails_admin.show_path(model_name: :duplicate_publication_group, id: group.id) }

        it 'shows the correct data for the group' do
          expect(page).to have_content pub1.id
          expect(page).to have_content pub2.id

          expect(page).to have_link 'Duplicate Publication'
          expect(page).to have_link 'A duplicate publication'

          expect(page).to have_content 'subtitle1'
          expect(page).to have_content 'subtitle2'

          expect(page).to have_content 'journal1'
          expect(page).to have_content 'journal2'

          expect(page).to have_content 'publisher1'
          expect(page).to have_content 'publisher2'

          expect(page).to have_content '2018-08-13'
          expect(page).to have_content '2018-08-14'

          expect(page).to have_content('Published').twice

          expect(page).to have_content 'volume1'
          expect(page).to have_content 'volume2'

          expect(page).to have_content 'issue1'
          expect(page).to have_content 'issue2'

          expect(page).to have_content 'edition1'
          expect(page).to have_content 'edition2'

          expect(page).to have_content 'pages1'
          expect(page).to have_content 'pages2'

          expect(page).to have_content 'issn1'
          expect(page).to have_content 'issn2'

          expect(page).to have_link 'https://doi.org/10.000/doi1', href: 'https://doi.org/10.000/doi1'
          expect(page).to have_link 'https://doi.org/10.000/doi2', href: 'https://doi.org/10.000/doi2'

          expect(page).to have_content 'Trade Journal Article'
          expect(page).to have_content 'Academic Journal Article'

          expect(page).to have_link 'Test1 User1'
          expect(page).to have_link 'Test2 User2'
          expect(page).to have_link 'Test3 User3'

          expect(page).to have_content 'Test2 Contributor2, Test1 Contributor1'
          expect(page).to have_content 'Test3 Contributor3'

          expect(page).to have_content 'pure-abc123'
          expect(page).to have_content 'pure-xyz789'
          expect(page).to have_content 'ai-abc123'
          expect(page).to have_content 'ai-xyz789'

          expect(page).to have_content pub1.created_at.strftime('%B %-d, %Y %-H:%M')
          expect(page).to have_content pub2.created_at.strftime('%B %-d, %Y %-H:%M')

          expect(page).to have_content "#{nd_pub1.id}, #{nd_pub2.id}"

          expect(page).to have_content 'Select'
          expect(page).to have_content 'Merge Target'
          expect(page).to have_no_content 'Delete'
        end

        it 'disables/enables buttons' do
          expect(page).to have_button 'Merge Selected', disabled: true
          expect(page).to have_button 'Ignore Selected', disabled: true
          check "selected_publication_ids_#{pub1.id}"
          check "selected_publication_ids_#{pub2.id}"
          expect(page).to have_button 'Merge Selected', disabled: true
          expect(page).to have_button 'Ignore Selected', disabled: false
          uncheck "selected_publication_ids_#{pub1.id}"
          find("#merge_target_publication_id_#{pub1.id}").set(true)
          expect(page).to have_button 'Merge Selected', disabled: false
          expect(page).to have_button 'Ignore Selected', disabled: true
        end
      end
    end

    context 'when the group has one publication' do
      let(:pub1_group) { group }

      describe 'the page content' do
        before { visit rails_admin.show_path(model_name: :duplicate_publication_group, id: group.id) }

        it 'shows the correct controls' do
          expect(page).to have_no_content 'Select'
          expect(page).to have_no_content 'Merge Target'
          expect(page).to have_no_content 'Merge Selected'
          expect(page).to have_no_content 'Ignore Selected'
          expect(page).to have_button 'Delete Group'
        end
      end
    end

    context 'when the group has no publications' do
      describe 'the page content' do
        before { visit rails_admin.show_path(model_name: :duplicate_publication_group, id: group.id) }

        it 'shows the correct controls' do
          expect(page).to have_no_content 'Select'
          expect(page).to have_no_content 'Merge Target'
          expect(page).to have_no_content 'Merge Selected'
          expect(page).to have_no_content 'Ignore Selected'
          expect(page).to have_button 'Delete Group'
        end
      end
    end

    describe 'the page layout' do
      before { visit rails_admin.show_path(model_name: :duplicate_publication_group, id: group.id) }

      it_behaves_like 'a page with the admin layout'
    end
  end

  context 'when the current user is not an admin' do
    before { authenticate_user }

    it 'redirects back to the home page with an error message' do
      visit rails_admin.show_path(model_name: :duplicate_publication_group, id: group.id)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
