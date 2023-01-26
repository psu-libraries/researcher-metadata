# frozen_string_literal: true

require 'component/component_spec_helper'

describe UnpaywallClient do
  let(:pub) { create(:publication,
                     doi: doi,
                     title: title) }
  let(:doi) { 'https://doi.org/10.1016/s0962-1849(05)80014-9' }
  let!(:title) { 'Stable characteristic evolution of generic three-dimensional single-black-hole spacetimes' }
  let(:client) { described_class.new }

  describe '#query_unpaywall' do
    let(:doi_json) { '{"doi" : "10.1016/s0962-1849(05)80014-9", "title" : "Stable characteristic evolution of generic three-dimensional single-black-hole spacetimes"}' }
    let(:doi_response) { instance_double UnpaywallResponse }

    context 'when the publication has a doi' do
      before do
        allow(HttpService).to receive(:get).with('https://api.unpaywall.org/v2/10.1016/s0962-1849(05)80014-9?email=openaccess@psu.edu').and_return(doi_json)
        allow(JSON).to receive(:parse).with(doi_json).and_return('parsed doi json')
        allow(UnpaywallResponse).to receive(:new).with('parsed doi json').and_return(doi_response)
      end

      let(:title) { 'Stable characteristic evolution of generic three-dimensional single-black-hole spacetimes' }

      it 'finds Unpaywall data by doi' do
        expect(client.query_unpaywall(pub)).to eq doi_response
      end
    end

    context 'when the publication does not have a doi' do
      let(:doi) { nil }

      context 'when the publication title can be found on Unpaywall' do
        before do
          allow(HttpService).to receive(:get).with('https://api.unpaywall.org/v2/search/?query=Stable+characteristic+evolution+of+generic+three-dimensional+single-black-hole+spacetimes&email=openaccess@psu.edu').and_return(title_json)
          allow(JSON).to receive(:parse).with(title_json).and_return(parsed_title_json)
          allow(UnpaywallResponse).to receive(:new).with(single_response).and_return(title_response)
        end

        let(:title_json) { '{"doi" : nil, "title" : "Stable characteristic evolution of generic three-dimensional single-black-hole spacetimes"}' }
        let(:parsed_title_json) { { 'elapsed_seconds' => 0.083, 'results' => [{ 'response' => { 'doi' => nil, 'title' => 'Stable characteristic evolution of generic three-dimensional single-black-hole spacetimes' } }] } }
        let(:single_response) { { 'doi' => nil, 'title' => 'Stable characteristic evolution of generic three-dimensional single-black-hole spacetimes' } }
        let(:title_response) { instance_double UnpaywallResponse }

        let(:title) { 'Stable characteristic evolution of generic three-dimensional single-black-hole spacetimes' }

        it 'returns a single response' do
          expect(client.query_unpaywall(pub)).to eq title_response
        end
      end

      context 'when the publication title cannot be found on Unpaywall' do
        before do
          allow(HttpService).to receive(:get).with('https://api.unpaywall.org/v2/search/?query=Stable+characteristic+evolution+of+generic+kinesiology&email=openaccess@psu.edu').and_return(empty_json)
          allow(JSON).to receive(:parse).with(empty_json).and_return({ 'elapsed_seconds' => 0.083, 'results' => [] })
          allow(UnpaywallResponse).to receive(:new).with('').and_return(empty_response)
        end

        let(:empty_json) { ' {"elapsed_seconds"=>0.083, "results"=>[]}' }
        let(:empty_response) { instance_double UnpaywallResponse }
        let(:title) { 'Stable characteristic evolution of generic kinesiology' }

        it 'returns an empty string' do
          expect(client.query_unpaywall(pub)).to eq empty_response
        end
      end
    end
  end

  describe '#query_unpaywall' do
    before { allow(HttpService).to receive(:get).with('https://api.unpaywall.org/v2/10.1016/s0962-1849(05)80014-9?email=openaccess@psu.edu').and_return(json) }

    let(:json) { '{"doi" : "10.1016/s0962-1849(05)80014-9", "title" : "Psychotherapy integration and the need for better theories of change: A rejoinder to Alford"}' }
    let(:response) { client.query_unpaywall(pub) }
    let(:title) { 'Stable characteristic evolution of generic three-dimensional single-black-hole spacetimes' }

    it 'finds Unpaywall data by doi' do
      expect(response.title).to eq 'Psychotherapy integration and the need for better theories of change: A rejoinder to Alford'
      expect(response.doi).to eq '10.1016/s0962-1849(05)80014-9'
    end
  end
end
