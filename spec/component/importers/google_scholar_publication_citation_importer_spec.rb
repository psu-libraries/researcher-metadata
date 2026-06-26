# frozen_string_literal: true

require 'component/component_spec_helper'

describe GoogleScholarPublicationCitationImporter do
  describe '#call' do
    let(:scraper) { instance_double(Utilities::GoogleScholarScraper) }
    let(:importer) { described_class.new(scraper: scraper) }

    let!(:publication_with_doi) { create(:publication, doi: 'https://doi.org/10.123/example') }
    let!(:publication_without_doi) { create(:publication, doi: nil) }

    before do
      allow(scraper).to receive(:fetch_publication_by_doi)
        .with('https://doi.org/10.123/example')
        .and_return(doi: '10.123/example', citations: 42)
    end

    it 'updates citation counts for DOI-matched publications only' do
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
  end
end
