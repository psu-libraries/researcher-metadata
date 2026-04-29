# frozen_string_literal: true

require 'component/component_spec_helper'

describe NIHProjects do
  let(:projects) { described_class.new(page_1_data) }
  let(:page_1_data) { { 'meta' => { 'total' => 3 }, 'results' => [p_data_1, p_data_2] } }
  let(:page_2_data) { { 'results' => [p_data_3] } }
  let(:api_client) { instance_double NIHAPIClient, projects_pages_count: 2 }
  let(:p_data_1) { double 'project data 1' }
  let(:p_data_2) { double 'project data 2' }
  let(:p_data_3) { double 'project data 3' }
  let(:p1) { instance_double NIHProject }
  let(:p2) { instance_double NIHProject }
  let(:p3) { instance_double NIHProject }

  before do
    allow(NIHAPIClient).to receive(:new).and_return api_client
    allow(api_client).to receive(:projects).with(1).and_return(page_1_data)
    allow(api_client).to receive(:projects).with(2).and_return(page_2_data)
    allow(NIHProject).to receive(:new).with(p_data_1).and_return p1
    allow(NIHProject).to receive(:new).with(p_data_2).and_return p2
    allow(NIHProject).to receive(:new).with(p_data_3).and_return p3
  end

  describe '.find_in_batches' do
    it 'yields an NIHProject to the given block for each project result from the NIH API request' do
      expect { |b| described_class.find_in_batches(&b) }.to yield_successive_args(p1, p2, p3)
    end
  end

  describe '#each' do
    it 'yields an NIHProject to the given block for each project in the given data' do
      expect { |b| projects.each(&b) }.to yield_successive_args(p1, p2)
    end
  end

  describe '#total_count' do
    it 'returns the total number of NIH projects' do
      expect(projects.total_count).to eq 3
    end
  end
end
