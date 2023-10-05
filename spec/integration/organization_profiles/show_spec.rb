# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'Organization Profile page', type: :feature do
  let!(:org) { create(:organization) }

  before do
    create_list(:user, 100)
    increment = 1
    User.find_in_batches(batch_size: 10, finish: User.last.id).each do |batch|
      published_ago = increment.months.ago
      batch.each do |user|
        pub1 = create(:sample_publication, published_on: published_ago)
        create(:authorship, publication: pub1, user: user)
        create(:user_organization_membership, user: user, organization: org, started_on: 12.months.ago)
      end
      increment += 1
    end
  end

  context 'when the organization does not exist' do
    it 'raises an ActiveRecord::RecordNotFound error' do
      expect { visit organization_profile_path(org.id + 1) }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  context 'when the organization does exist' do
    it 'displays a list of publications in reverse chronological order with full pagination features' do
      visit organization_profile_path(org.id)
      expect(page).to have_content org.name
      expect(page).to have_content User.first.publications.first.title
      expect(page).to have_content User.first.publications.first.preferred_journal_title
      expect(page).to have_content User.first.publications.first.published_on.year
      expect(page).to have_content User.first.name
      expect(page).not_to have_content User.last.publications.first.title
      expect(page).to have_content 'Displaying publications 1 - 25 of 100 in total'
      click_link '3'
      expect(page).to have_content 'Displaying publications 51 - 75 of 100 in total'
      expect(page).to have_link '« First'
      expect(page).to have_link '‹ Prev'
      expect(page).to have_link 'Next ›'
      expect(page).to have_link 'Last »'
      click_link 'Last »'
      expect(page).not_to have_content User.first.publications.first.title
      expect(page).to have_content User.last.publications.first.title
    end
  end
end
