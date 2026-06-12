# frozen_string_literal: true

require 'component/component_spec_helper'

describe GoogleScholarProfileImporter do
  describe '#call' do
    let(:scraper) { instance_double(Utilities::GoogleScholarScraper, total_credits_used: 0, credit_budget_exceeded?: false) }
    let(:importer) { described_class.new(scraper: scraper) }

    context 'when an active user already has a Google Scholar ID' do
      let!(:user) { create(:user, :with_psu_identity, google_scholar_id: 'known-scholar-id') }

      before do
        allow(scraper).to receive(:fetch_profile).with('known-scholar-id').and_return(
          scholar_id: 'known-scholar-id',
          h_index: 12,
          citation_total: 345,
          publications: []
        )
      end

      it 'imports h-index and total citation metrics from the known profile' do
        importer.call

        user.reload
        expect(user.google_scholar_id).to eq 'known-scholar-id'
        expect(user.google_scholar_h_index).to eq 12
        expect(user.google_scholar_citation_total).to eq 345
        expect(user.google_scholar_imported_at).to be_present
      end

      it 'records the attempt and clears the not-found flag' do
        user.update!(google_scholar_not_found: true)

        importer.call

        user.reload
        expect(user.google_scholar_checked_at).to be_present
        expect(user.google_scholar_not_found).to be false
      end
    end

    context 'when an active user has a Google Scholar URL in their Activity Insight profile' do
      let!(:user) do
        create(:user, :with_psu_identity,
               google_scholar_id: nil,
               ai_google_scholar: 'https://scholar.google.com/citations?hl=en&user=ai-scholar-id')
      end

      before do
        allow(scraper).to receive(:fetch_profile).with('ai-scholar-id').and_return(
          scholar_id: 'ai-scholar-id',
          h_index: 7,
          citation_total: 99,
          publications: []
        )
        allow(scraper).to receive(:search_profiles)
      end

      it 'uses the ID extracted from the AI URL without doing name discovery' do
        importer.call

        user.reload
        expect(user.google_scholar_id).to eq 'ai-scholar-id'
        expect(user.google_scholar_h_index).to eq 7
        expect(user.google_scholar_citation_total).to eq 99
        expect(scraper).to have_received(:fetch_profile).with('ai-scholar-id')
        expect(scraper).not_to have_received(:search_profiles)
      end

      it 'stores the scholar_id returned by the fetched profile' do
        allow(scraper).to receive(:fetch_profile).with('ai-scholar-id').and_return(
          scholar_id: 'canonical-scholar-id',
          h_index: 7,
          citation_total: 99,
          publications: []
        )

        importer.call

        expect(user.reload.google_scholar_id).to eq 'canonical-scholar-id'
      end
    end

    context 'when an active user does not have a Google Scholar ID' do
      let!(:user) { create(:user, :with_psu_identity, first_name: 'Jane', last_name: 'Scholar') }

      before do
        create(:sample_publication, user: user, doi: 'https://doi.org/10.123/first')
        create(:sample_publication, user: user, doi: 'https://doi.org/10.123/second')

        allow(scraper).to receive(:search_profiles).with('Jane Scholar').and_return(
          [{ scholar_id: 'discovered-scholar-id' }]
        )
        allow(scraper).to receive(:fetch_profile).with('discovered-scholar-id').and_return(
          scholar_id: 'discovered-scholar-id',
          h_index: 18,
          citation_total: 1200,
          publications: [
            { title: 'First', doi: '10.123/first' },
            { title: 'Second', doi: '10.123/second' }
          ]
        )
      end

      it 'discovers the profile by two DOI matches and imports profile metrics' do
        importer.call

        user.reload
        expect(user.google_scholar_id).to eq 'discovered-scholar-id'
        expect(user.google_scholar_h_index).to eq 18
        expect(user.google_scholar_citation_total).to eq 1200
        expect(user.google_scholar_imported_at).to be_present
      end
    end

    context 'when an active user has a middle name' do
      let!(:user) do
        create(:user, :with_psu_identity, first_name: 'Jane', middle_name: 'Quinn', last_name: 'Scholar')
      end

      before do
        create(:sample_publication, user: user, doi: 'https://doi.org/10.123/first')
        allow(scraper).to receive(:search_profiles).and_return([])
      end

      it 'searches with first and last name only' do
        importer.call

        expect(scraper).to have_received(:search_profiles).with('Jane Scholar')
      end
    end

    context 'when a user is inactive' do
      let!(:user) { create(:user, google_scholar_id: 'inactive-scholar-id') }

      it 'does not import the user' do
        allow(scraper).to receive(:fetch_profile)

        importer.call

        expect(scraper).not_to have_received(:fetch_profile)
        expect(user.reload.google_scholar_imported_at).to be_nil
      end
    end

    context 'when an active user was checked within the refresh window' do
      let!(:user) do
        create(:user, :with_psu_identity,
               google_scholar_id: 'known-scholar-id',
               google_scholar_checked_at: 10.days.ago)
      end

      it 'does not fetch the profile again' do
        allow(scraper).to receive(:fetch_profile)

        importer.call

        expect(scraper).not_to have_received(:fetch_profile)
      end
    end

    context 'when an active user was checked longer ago than the refresh window' do
      let!(:user) do
        create(:user, :with_psu_identity,
               google_scholar_id: 'known-scholar-id',
               google_scholar_checked_at: 121.days.ago)
      end

      it 'fetches the profile again' do
        allow(scraper).to receive(:fetch_profile).with('known-scholar-id').and_return(
          scholar_id: 'known-scholar-id',
          h_index: 12,
          citation_total: 345,
          publications: []
        )

        importer.call

        expect(scraper).to have_received(:fetch_profile).with('known-scholar-id')
      end
    end

    context 'when a user is flagged not found and has no Scholar ID' do
      let!(:user) do
        create(:user, :with_psu_identity,
               google_scholar_id: nil,
               ai_google_scholar: nil,
               google_scholar_not_found: true)
      end

      it 'skips the user entirely' do
        allow(scraper).to receive(:search_profiles)
        allow(scraper).to receive(:fetch_profile)

        importer.call

        expect(scraper).not_to have_received(:search_profiles)
        expect(scraper).not_to have_received(:fetch_profile)
      end
    end

    context 'when a user is flagged not found but now has a Scholar ID' do
      let!(:user) do
        create(:user, :with_psu_identity,
               google_scholar_id: 'late-added-id',
               google_scholar_not_found: true)
      end

      it 'fetches the profile and clears the flag' do
        allow(scraper).to receive(:fetch_profile).with('late-added-id').and_return(
          scholar_id: 'late-added-id',
          h_index: 3,
          citation_total: 40,
          publications: []
        )

        importer.call

        user.reload
        expect(user.google_scholar_not_found).to be false
        expect(user.google_scholar_imported_at).to be_present
      end
    end

    context 'when discovery completes without finding a match' do
      let!(:user) { create(:user, :with_psu_identity, first_name: 'Jane', last_name: 'Scholar') }

      before do
        create(:sample_publication, user: user, doi: 'https://doi.org/10.123/first')
        allow(scraper).to receive(:search_profiles).with('Jane Scholar').and_return([])
      end

      it 'marks the user as not found and records the attempt' do
        importer.call

        user.reload
        expect(user.google_scholar_not_found).to be true
        expect(user.google_scholar_checked_at).to be_present
        expect(user.google_scholar_imported_at).to be_nil
      end
    end

    context 'when discovery comes back empty because the credit budget ran out mid-user' do
      let!(:user) { create(:user, :with_psu_identity, first_name: 'Jane', last_name: 'Scholar') }

      before do
        create(:sample_publication, user: user, doi: 'https://doi.org/10.123/first')
        # false for the pre-user check in #call, true when checked after discovery
        allow(scraper).to receive(:credit_budget_exceeded?).and_return(false, true)
        allow(scraper).to receive(:search_profiles).and_return([])
      end

      it 'does not mark the user as not found' do
        importer.call

        user.reload
        expect(user.google_scholar_not_found).to be false
        expect(user.google_scholar_checked_at).to be_nil
      end
    end

    context 'when the credit budget is already exhausted at the start of the run' do
      let!(:user) { create(:user, :with_psu_identity, google_scholar_id: 'known-scholar-id') }

      before do
        allow(scraper).to receive(:credit_budget_exceeded?).and_return(true)
      end

      it 'stops without fetching or writing tracking fields' do
        allow(scraper).to receive(:fetch_profile)

        importer.call

        expect(scraper).not_to have_received(:fetch_profile)
        expect(user.reload.google_scholar_checked_at).to be_nil
      end
    end

    context 'when fetching a known profile fails transiently' do
      let!(:user) { create(:user, :with_psu_identity, google_scholar_id: 'known-scholar-id') }

      before do
        allow(scraper).to receive(:fetch_profile).with('known-scholar-id').and_return(nil)
      end

      it 'leaves all tracking fields untouched so the next run retries' do
        importer.call

        user.reload
        expect(user.google_scholar_checked_at).to be_nil
        expect(user.google_scholar_not_found).to be false
        expect(user.google_scholar_imported_at).to be_nil
      end
    end

    context 'when a user has no Scholar ID and no publications' do
      let!(:user) do
        create(:user, :with_psu_identity, google_scholar_id: nil, ai_google_scholar: nil)
      end

      it 'skips without searching and without writing tracking fields' do
        allow(scraper).to receive(:search_profiles)

        importer.call

        expect(scraper).not_to have_received(:search_profiles)
        user.reload
        expect(user.google_scholar_checked_at).to be_nil
        expect(user.google_scholar_not_found).to be false
      end
    end
  end
end
