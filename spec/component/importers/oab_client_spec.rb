# frozen_string_literal: true

require 'component/component_spec_helper'

describe OABClient do
  let(:pub) { create(:publication,
                     doi: doi,
                     title: title) }
  let(:doi) { 'https://doi.org/10.1016/s0962-1849(05)80014-9' }
  let!(:title) { 'Stable characteristic evolution of generic three-dimensional single-black-hole spacetimes' }
  let(:client) { described_class }

  describe '.query_open_access_button' do
    let(:doi_json) { '{"doi" : "10.1016/s0962-1849(05)80014-9", "title" : "Stable characteristic evolution of generic three-dimensional single-black-hole spacetimes"}' }
    let(:doi_response) { instance_double OABResponse }

    context 'when the publication has a doi' do
      before do
        allow(HttpService).to receive(:get).with('https://api.openaccessbutton.org/find?id=10.1016%2Fs0962-1849%2805%2980014-9').and_return(doi_json)
        allow(JSON).to receive(:parse).with(doi_json).and_return('parsed doi json')
        allow(OABResponse).to receive(:new).with('parsed doi json').and_return(doi_response)
      end

      let(:title) { 'Stable characteristic evolution of generic three-dimensional single-black-hole spacetimes' }

      it 'finds OAB data by doi' do
        expect(client.query_open_access_button(pub)).to eq doi_response
      end
    end

    context 'when the publication does not have a doi' do
      let(:doi) { nil }

      context 'when the publication title can be found on OAB' do
        before do
          allow(HttpService).to receive(:get).with('https://api.openaccessbutton.org/find?title=Stable+characteristic+evolution+of+generic+three-dimensional+single-black-hole+spacetimes').and_return(title_json)
          allow(JSON).to receive(:parse).with(title_json).and_return(parsed_title_json)
          allow(OABResponse).to receive(:new).with(parsed_title_json).and_return(title_response)
        end

        let(:title_json) { '"url": "http://arxiv.org/pdf/gr-qc/9801069", "metadata": { "doi": "10.1103/physrevlett.80.3915"}' }
        let(:parsed_title_json) { { 'url' => 'http://arxiv.org/pdf/gr-qc/9801069', 'metadata' => { 'doi' => '10.1103/physrevlett.80.3915' } } }
        let(:title_response) { instance_double OABResponse }

        let(:title) { 'Stable characteristic evolution of generic three-dimensional single-black-hole spacetimes' }

        it 'returns a single response' do
          expect(client.query_open_access_button(pub)).to eq title_response
        end
      end

      context 'when the publication title cannot be found on Unpaywall' do
        before do
          allow(HttpService).to receive(:get).with('https://api.openaccessbutton.org/find?title=Stable+characteristic+evolution+of+generic+kinesiology').and_return(empty_json)
          allow(JSON).to receive(:parse).with(empty_json).and_return(parsed_empty_json)
          allow(OABResponse).to receive(:new).with(parsed_empty_json).and_return(empty_response)
        end

        let(:empty_json) { '{ "metadata": { "title": "Stable+characteristic+evolution+of+generic+kinesiology" }}' }
        let(:parsed_empty_json) { { 'metadata' => { 'title' => 'Stable+characteristic+evolution+of+generic+kinesiology' } } }
        let(:empty_response) { instance_double OABResponse }
        let(:title) { 'Stable characteristic evolution of generic kinesiology' }

        it 'returns an empty string' do
          expect(client.query_open_access_button(pub)).to eq empty_response
        end
      end
    end

    context 'when the publication type is Extension Publication' do
      before { allow(OABResponse).to receive(:new).with({}).and_return(empty_response) }

      let(:pub) { create(:publication,
                         doi: nil,
                         title: title,
                         publication_type: 'Extension Publication') }

      let(:empty_response) { instance_double OABResponse }

      it 'returns an empty hash' do
        expect(client.query_open_access_button(pub)).to eq empty_response
      end
    end
  end

  describe '#query_open_access_button' do
    before { allow(HttpService).to receive(:get).with('https://api.openaccessbutton.org/find?id=10.1103%2Fphysrevlett.80.3915').and_return(json) }

    let(:json) { '{
        "url": "http://arxiv.org/pdf/gr-qc/9801069",
        "metadata": {
          "doi": "10.1103/physrevlett.80.3915"
        }
      }' }
    let(:title) { 'Stable characteristic evolution of generic three-dimensional single-black-hole spacetimes' }
    let(:doi) { 'https://doi.org/10.1103/physrevlett.80.3915' }
    let(:response) { client.query_open_access_button(pub) }

    it 'finds OAB data by doi' do
      expect(response.url).to eq 'http://arxiv.org/pdf/gr-qc/9801069'
      expect(response.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
    end
  end
end
