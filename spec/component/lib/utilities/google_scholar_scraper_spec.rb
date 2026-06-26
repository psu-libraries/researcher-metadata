# frozen_string_literal: true

require 'component/component_spec_helper'
require 'utilities/google_scholar_scraper'

describe Utilities::GoogleScholarScraper do
  subject(:scraper) { described_class.new(api_key: 'test-key') }

  describe '#search_profiles', vcr: false do
    let(:structured_hit) do
      {
        'organic_results' => [
          {
            'title' => 'Anne Verplanck - Google Scholar',
            'link' => 'https://scholar.google.com/citations?user=D680R8QAAAAJ&hl=en'
          },
          {
            'title' => 'John Doe - Google Scholar',
            'link' => 'https://scholar.google.com/citations?user=WRONGID&hl=en'
          }
        ]
      }.to_json
    end

    let(:empty_response) { { 'organic_results' => [] }.to_json }

    before do
      stub_request(:get, /api\.scraperapi\.com\/structured\/google\/search\/v1/)
        .to_return(status: 200, body: structured_hit, headers: { 'sa-credit-cost' => '25' })
    end

    it 'returns candidates whose title contains first and last name' do
      results = scraper.search_profiles('Anne Verplanck')

      expect(results.length).to eq 1
      expect(results.first[:scholar_id]).to eq 'D680R8QAAAAJ'
    end

    it 'skips results where the title does not match the faculty name' do
      results = scraper.search_profiles('Anne Verplanck')

      expect(results.pluck(:scholar_id)).not_to include('WRONGID')
    end

    it 'matches a candidate whose first name differs by one character (e.g. Sergei vs Sergey)' do
      stub_request(:get, /api\.scraperapi\.com\/structured\/google\/search\/v1/)
        .to_return(
          status: 200,
          body: {
            'organic_results' => [
              {
                'title' => 'Sergey Tabachnikov - Google Scholar',
                'link' => 'https://scholar.google.com/citations?user=SOT2AAAAAAAJ&hl=en'
              }
            ]
          }.to_json,
          headers: { 'sa-credit-cost' => '25' }
        )

      results = scraper.search_profiles('Sergei Tabachnikov')

      expect(results.length).to eq 1
      expect(results.first[:scholar_id]).to eq 'SOT2AAAAAAAJ'
    end

    it 'matches a candidate whose first name is a longer variant (e.g. Dave vs David)' do
      stub_request(:get, /api\.scraperapi\.com\/structured\/google\/search\/v1/)
        .to_return(
          status: 200,
          body: {
            'organic_results' => [
              {
                'title' => 'David Mauger - Google Scholar',
                'link' => 'https://scholar.google.com/citations?user=DTM5AAAAAAAJ&hl=en'
              }
            ]
          }.to_json,
          headers: { 'sa-credit-cost' => '25' }
        )

      results = scraper.search_profiles('Dave Mauger')

      expect(results.length).to eq 1
      expect(results.first[:scholar_id]).to eq 'DTM5AAAAAAAJ'
    end

    it 'returns an empty array when organic_results is empty' do
      stub_request(:get, /api\.scraperapi\.com\/structured\/google\/search\/v1/)
        .to_return(status: 200, body: empty_response, headers: { 'sa-credit-cost' => '25' })

      expect(scraper.search_profiles('Nobody Here')).to eq []
    end

    it 'returns nil when ScraperAPI fails' do
      stub_request(:get, /api\.scraperapi\.com\/structured\/google\/search\/v1/)
        .to_return(status: 500, body: '')

      expect(scraper.search_profiles('Anne Verplanck')).to be_nil
    end

    it 'sends the unquoted name with psu.edu and site: operator' do
      scraper.search_profiles('Anne Verplanck')

      expect(WebMock).to have_requested(:get, /api\.scraperapi\.com\/structured\/google\/search\/v1/)
        .with(query: hash_including('query' => 'Anne Verplanck psu.edu site:scholar.google.com/citations'))
    end

    it 'tracks credit cost' do
      expect { scraper.search_profiles('Anne Verplanck') }
        .to change(scraper, :total_credits_used).by(25)
    end
  end

  describe '#fetch_profile', vcr: false do
    let(:profile_html) do
      <<~HTML
        <html><body>
          <div id="gsc_prf_ivh">
            Materials Research Institute, Pennsylvania State University
            <a class="gsc_prf_ila" href="/citations">Verified email at psu.edu</a>
          </div>
          <table id="gsc_rsb_st">
            <tr>
              <td class="gsc_rsb_sc1">Citations</td>
              <td class="gsc_rsb_std">1500</td>
            </tr>
            <tr>
              <td class="gsc_rsb_sc1">h-index</td>
              <td class="gsc_rsb_std">20</td>
            </tr>
          </table>
          <tbody id="gsc_a_b"></tbody>
        </body></html>
      HTML
    end

    let(:no_affiliation_html) do
      <<~HTML
        <html><body>
          <table id="gsc_rsb_st">
            <tr>
              <td class="gsc_rsb_sc1">h-index</td>
              <td class="gsc_rsb_std">5</td>
            </tr>
          </table>
          <tbody id="gsc_a_b"></tbody>
        </body></html>
      HTML
    end

    before do
      stub_request(:get, /api\.scraperapi\.com\//)
        .to_return(status: 200, body: profile_html, headers: { 'sa-credit-cost' => '10' })
    end

    it 'returns the verified email domain from the profile page' do
      profile = scraper.fetch_profile('D680R8QAAAAJ')

      expect(profile[:email_domain]).to eq 'psu.edu'
    end

    it 'returns the affiliation text from the profile page' do
      profile = scraper.fetch_profile('D680R8QAAAAJ')

      expect(profile[:affiliation]).to eq 'Materials Research Institute, Pennsylvania State University'
    end

    it 'returns nil email_domain when the profile has no affiliation div' do
      stub_request(:get, /api\.scraperapi\.com\//)
        .to_return(status: 200, body: no_affiliation_html, headers: { 'sa-credit-cost' => '10' })

      profile = scraper.fetch_profile('D680R8QAAAAJ')

      expect(profile[:email_domain]).to be_nil
    end

    it 'returns nil affiliation when the profile has no affiliation div' do
      stub_request(:get, /api\.scraperapi\.com\//)
        .to_return(status: 200, body: no_affiliation_html, headers: { 'sa-credit-cost' => '10' })

      profile = scraper.fetch_profile('D680R8QAAAAJ')

      expect(profile[:affiliation]).to be_nil
    end

    it 'fetches from ScraperAPI on every call instead of caching' do
      scraper.fetch_profile('D680R8QAAAAJ')
      scraper.fetch_profile('D680R8QAAAAJ')

      expect(WebMock).to have_requested(:get, /api\.scraperapi\.com\//).twice
    end
  end

  describe '#fetch_profile_page0', vcr: false do
    let(:profile_html) do
      <<~HTML
        <html><body>
          <div id="gsc_prf_ivh">
            Materials Research Institute, Pennsylvania State University
            <a class="gsc_prf_ila" href="/citations">Verified email at psu.edu</a>
          </div>
          <table id="gsc_rsb_st">
            <tr>
              <td class="gsc_rsb_sc1">Citations</td>
              <td class="gsc_rsb_std">1500</td>
            </tr>
            <tr>
              <td class="gsc_rsb_sc1">h-index</td>
              <td class="gsc_rsb_std">20</td>
            </tr>
          </table>
          <tbody id="gsc_a_b"></tbody>
        </body></html>
      HTML
    end

    before do
      stub_request(:get, /api\.scraperapi\.com\//)
        .to_return(status: 200, body: profile_html, headers: { 'sa-credit-cost' => '10' })
    end

    it 'returns a profile hash with the correct shape' do
      profile = scraper.fetch_profile_page0('D680R8QAAAAJ')

      expect(profile).to include(
        scholar_id: 'D680R8QAAAAJ',
        h_index: 20,
        citation_total: 1500,
        email_domain: 'psu.edu',
        affiliation: 'Materials Research Institute, Pennsylvania State University',
        publications: []
      )
    end

    it 'makes exactly one HTTP request regardless of page size' do
      scraper.fetch_profile_page0('D680R8QAAAAJ')

      expect(WebMock).to have_requested(:get, /api\.scraperapi\.com\//).once
    end

    it 'returns :scraper_error when ScraperAPI returns a non-200 response' do
      stub_request(:get, /api\.scraperapi\.com\//)
        .to_return(status: 500, body: '')

      expect(scraper.fetch_profile_page0('D680R8QAAAAJ')).to eq :scraper_error
    end

    it 'returns nil when the page loads but the profile is empty' do
      stub_request(:get, /api\.scraperapi\.com\//)
        .to_return(status: 200, body: '<html><body></body></html>', headers: { 'sa-credit-cost' => '10' })

      expect(scraper.fetch_profile_page0('D680R8QAAAAJ')).to be_nil
    end

    it 'tracks credit cost' do
      expect { scraper.fetch_profile_page0('D680R8QAAAAJ') }
        .to change(scraper, :total_credits_used).by(10)
    end
  end
end
