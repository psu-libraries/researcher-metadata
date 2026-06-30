# frozen_string_literal: true

require 'component/component_spec_helper'

describe GoogleScholarPublicationCitationImporter do
  describe '#call' do
    let(:scraper) { instance_double(Utilities::GoogleScholarScraper) }
    let(:importer) { described_class.new(scraper: scraper) }

    let!(:publication_with_doi) do
      create(:publication, doi: 'https://doi.org/10.123/example', title: 'Machine Learning in Libraries')
    end
    let!(:publication_without_doi) { create(:publication, doi: nil) }

    before do
      allow(scraper).to receive(:fetch_publication_by_doi)
        .with('https://doi.org/10.123/example')
        .and_return(doi: '10.123/example', title: 'Machine Learning in Librariex', citations: 42)
    end

    it 'updates citation counts for publications with DOIs only' do
      importer.call

      expect(publication_with_doi.reload.google_scholar_citation_count).to eq 42
      expect(publication_without_doi.reload.google_scholar_citation_count).to be_nil
      expect(scraper).not_to have_received(:fetch_publication_by_doi).with(nil)
    end

    context 'when the DOI search does not find a result' do
      before do
        allow(scraper).to receive(:fetch_publication_by_doi)
          .with('https://doi.org/10.123/example')
          .and_return(nil)
      end

      it 'leaves the publication unchanged' do
        importer.call

        expect(publication_with_doi.reload.google_scholar_citation_count).to be_nil
      end
    end

    context 'when the returned title matches the stored title by more than 85%' do
      before do
        allow(scraper).to receive(:fetch_publication_by_doi)
          .with('https://doi.org/10.123/example')
          .and_return(doi: '10.123/example', title: 'Machine Learning in Librariex', citations: 7)
      end

      it 'updates the citation count' do
        importer.call

        expect(publication_with_doi.reload.google_scholar_citation_count).to eq 7
      end
    end

    context 'when the returned title does not match the stored title by more than 85%' do
      before do
        allow(scraper).to receive(:fetch_publication_by_doi)
          .with('https://doi.org/10.123/example')
          .and_return(doi: '10.123/example', title: 'Completely Different Publication', citations: 99)
      end

      it 'does not update the citation count' do
        importer.call

        expect(publication_with_doi.reload.google_scholar_citation_count).to be_nil
      end
    end
  end
end
