# frozen_string_literal: true

require 'component/component_spec_helper'
require 'utilities/google_scholar_scraper'

describe Utilities::GoogleScholarScraper do
  subject(:scraper) { described_class.new(api_key: 'test-key') }

  describe '#search_profiles', vcr: false do
    let(:html_with_profile) do
      <<~HTML
        <html><body>
          <div id="gs_res_ccl_top">
            <div class="gs_ai gs_scl gs_afn">
              <a href="/citations?user=D680R8QAAAAJ&amp;hl=en&amp;oi=ao">Anne Verplanck</a>
            </div>
          </div>
          <div class="gs_r">
            <a href="/citations?user=D680R8QAAAAJ&amp;hl=en&amp;oi=sra">co-author</a>
            <a href="/citations?user=IvlHCi0AAAAJ&amp;hl=en&amp;oi=sra">co-author 2</a>
          </div>
        </body></html>
      HTML
    end

    let(:html_no_profiles) do
      '<html><body><p>No results</p></body></html>'
    end

    before do
      stub_request(:get, /api\.scraperapi\.com/)
        .to_return(status: 200, body: html_with_profile, headers: { 'sa-credit-cost' => '25' })
    end

    it 'returns only oi=ao profile candidates, not oi=sra co-author links' do
      results = scraper.search_profiles('Anne Verplanck')

      expect(results.length).to eq 1
      expect(results.first[:scholar_id]).to eq 'D680R8QAAAAJ'
    end

    it 'returns an empty array when no oi=ao links are present' do
      stub_request(:get, /api\.scraperapi\.com/)
        .to_return(status: 200, body: html_no_profiles, headers: { 'sa-credit-cost' => '25' })

      expect(scraper.search_profiles('Nobody Here')).to eq []
    end

    it 'returns an empty array when ScraperAPI fails' do
      stub_request(:get, /api\.scraperapi\.com/)
        .to_return(status: 500, body: '')

      expect(scraper.search_profiles('Anne Verplanck')).to eq []
    end

    it 'appends psu.edu to the query' do
      scraper.search_profiles('Anne Verplanck')

      expect(WebMock).to have_requested(:get, /api\.scraperapi\.com/)
        .with(query: hash_including('url' => /Anne\+Verplanck.*psu\.edu/))
    end

    it 'uses render: false (cheaper)' do
      scraper.search_profiles('Anne Verplanck')

      expect(WebMock).to have_requested(:get, /api\.scraperapi\.com/)
        .with(query: hash_including('render' => 'false'))
    end
  end
end
