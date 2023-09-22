# frozen_string_literal: true

require 'component/component_spec_helper'

describe ScholarsphereClient do
  let(:pub) { create(:publication,
                     doi: doi) }
  let(:doi) { 'https://doi.org/10.1016/s0962-1849(05)80014-9' }
  let(:client) { described_class }

  describe '#doi_query' do
    context 'when the publication has a doi' do
      before do
        allow(HTTParty).to receive(:get).with('https://scholarsphere.psu.edu/api/v1/dois/10.1016/s0962-1849(05)80014-9', { headers: { 'X-API-KEY' => 'secret_key' } }).and_return('http_response')
        allow(ScholarsphereResponse).to receive(:new).with('http_response').and_return(ss_response)
      end

      let(:ss_response) { instance_double ScholarsphereResponse }

      it 'finds Unpaywall data by doi' do
        expect(client.doi_query(pub)).to eq ss_response
      end
    end

    context 'when the publication does not have a doi' do
      let(:doi) { nil }
      let(:empty_response) { instance_double ScholarsphereResponse }

      before do
        allow(ScholarsphereResponse).to receive(:new).with('').and_return(empty_response)
      end

      it 'returns an empty string' do
        expect(client.doi_query(pub)).to eq empty_response
      end
    end
  end
end
