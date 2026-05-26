# frozen_string_literal: true

require 'component/component_spec_helper'

describe GoogleScholarProfileImporter do
  describe '#call' do
    let(:scraper) { instance_double(GoogleScholarScraper) }
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

    context 'when a user is inactive' do
      let!(:user) { create(:user, google_scholar_id: 'inactive-scholar-id') }

      it 'does not import the user' do
        expect(scraper).not_to receive(:fetch_profile)

        importer.call

        expect(user.reload.google_scholar_imported_at).to be_nil
      end
    end
  end
end
