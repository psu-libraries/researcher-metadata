# frozen_string_literal: true

require 'component/component_spec_helper'

describe UnpaywallResponse do
  let(:response) { described_class.new(json) }
  let(:json) { JSON.parse(Rails.root.join('spec', 'fixtures', 'unpaywall1.json').read) }

  describe '#doi' do
    it 'returns doi' do
      expect(response.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
    end
  end

  describe '#title' do
    context 'when a title is present' do
      it 'returns title' do
        expect(response.title).to eq 'Stable Characteristic Evolution of Generic Three-Dimensional Single-Black-Hole Spacetimes'
      end
    end

    context 'when the response is empty' do
      let(:json) { '' }

      it 'returns an empty string' do
        expect(response.title).to eq ''
      end
    end
  end

  describe '#matchable_title' do
    it 'returns a formatted title' do
      expect(response.matchable_title).to eq 'stablecharacteristicevolutionofgenericthreedimensionalsingleblackholespacetimes'
    end
  end

  describe '#is_oa' do
    it 'returns is_oa' do
      expect(response.is_oa).to be true
    end
  end

  describe '#oa_status' do
    it 'returns oa_status' do
      expect(response.oa_status).to eq 'green'
    end
  end

  describe '#oa_locations' do
    context 'when there are no oa locations' do
      let(:json) { { 'doi' => '10.1016/s0962-1849(05)80014-9',
                     'doi_url' => 'https://doi.org/10.1016/s0962-1849(05)80014-9',
                     'title' => 'Psychotherapy integration and the need for better theories of change: A rejoinder to Alford',
                     'oa_locations' => [] }}
      let(:response) { described_class.new(json) }

      it 'returns an empty array' do
        expect(response.oa_locations).to eq ([])
      end
    end

    context 'when there is an oa location' do
      let(:first) { response.oa_locations.first }

      it 'returns an array of oa locations' do
        expect(response.oa_locations.length).to eq 2
        expect(first.url_for_landing_page).to eq 'http://arxiv.org/abs/gr-qc/9801069'
        expect(first.url_for_pdf).to eq 'http://arxiv.org/pdf/gr-qc/9801069'
        expect(first.host_type).to eq 'repository'
        expect(first.is_best).to be true
        expect(first.license).to be_nil
        expect(first.oa_date).to be_nil
        expect(first.updated).to eq '2017-10-20T16:41:23.656642'
        expect(first.version).to eq 'submittedVersion'
      end
    end
  end

  describe '#oal_urls' do
    context 'when there are no oa locations' do
      let(:json) { { 'doi' => '10.1016/s0962-1849(05)80014-9',
                     'doi_url' => 'https://doi.org/10.1016/s0962-1849(05)80014-9',
                     'title' => 'Psychotherapy integration and the need for better theories of change: A rejoinder to Alford',
                     'oa_locations' => [] }}
      let(:response) { described_class.new(json) }

      it 'returns an empty hash' do
        expect(response.oal_urls).to eq ({})
      end
    end

    context 'when there are oa locations' do
      it 'the keys are the oa location urls' do
        expect(response.oal_urls.keys).to eq ['http://arxiv.org/pdf/gr-qc/9801069', 'https://cdr.lib.unc.edu/downloads/hm50v1675']
      end
    end
  end

  describe '#oa_locations_embargoed' do
    it 'returns oa_locations_embargoed' do
      expect(response.oa_locations_embargoed).to eq ([])
    end
  end

  describe '#updated' do
    it 'returns updated' do
      expect(response.updated).to eq '2022-06-02T04:45:26.720108'
    end
  end
end
