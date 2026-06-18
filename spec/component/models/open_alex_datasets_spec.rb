# frozen_string_literal: true

require 'component/component_spec_helper'

describe OpenAlexDatasets do
  let(:datasets) { described_class.new(page_1_data) }
  let(:page_1_data) { { 'meta' => { 'next_cursor' => 'abc123' }, 'results' => [w_data_1, w_data_2] } }
  let(:page_2_data) { { 'meta' => { 'next_cursor' => nil }, 'results' => [w_data_3] } }
  let(:api_client) { instance_double(OpenAlexAPIClient) }
  let(:w_data_1) { double 'work data 1' }
  let(:w_data_2) { double 'work data 2' }
  let(:w_data_3) { double 'work data 3' }
  let(:w1) { instance_double OpenAlexWork }
  let(:w2) { instance_double OpenAlexWork }
  let(:w3) { instance_double OpenAlexWork }

  before do
    allow(OpenAlexAPIClient).to receive(:new).and_return api_client
    allow(api_client).to receive(:get_works).with(type: 'dataset', cursor: '*').and_return(page_1_data)
    allow(api_client).to receive(:get_works).with(type: 'dataset', cursor: 'abc123').and_return(page_2_data)
    allow(OpenAlexWork).to receive(:new).with(w_data_1).and_return w1
    allow(OpenAlexWork).to receive(:new).with(w_data_2).and_return w2
    allow(OpenAlexWork).to receive(:new).with(w_data_3).and_return w3
  end

  describe '.find_in_batches' do
    it 'yields an OpenAlexWork to the given block for each work result from the Open Alex API request' do
      expect { |b| described_class.find_in_batches(&b) }.to yield_successive_args(w1, w2, w3)
    end
  end

  describe '#each' do
    it 'yields an OpenAlexWork to the given block for each work in the given data' do
      expect { |b| datasets.each(&b) }.to yield_successive_args(w1, w2)
    end
  end

  describe '#next_cursor' do
    it 'returns the next_cursor value from the given metadata' do
      expect(datasets.next_cursor).to eq 'abc123'
    end
  end
end
