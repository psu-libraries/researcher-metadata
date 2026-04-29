# frozen_string_literal: true

require 'component/component_spec_helper'

describe NIHAPIClient do # rubocop:disable RSpec/SpecFilePathFormat
  let(:client) { described_class.new }

  let(:single_project) { instance_double HTTParty::Response, body: 'single project' }
  let(:projects_page_1) { instance_double HTTParty::Response, body: 'projects page 1' }
  let(:projects_page_2) { instance_double HTTParty::Response, body: 'projects page 2' }
  let(:publications) { instance_double HTTParty::Response, body: 'publications' }
  let(:pm_pub_1) { instance_double HTTParty::Response, body: 'publication 1' }
  let(:pm_pub_2) { instance_double HTTParty::Response, body: 'publication 2' }
  let(:projects) { instance_double NIHProjects, total_count: projects_count }
  let(:projects_count) { 1 }

  before do
    allow(HTTParty).to receive(:post).with(
      'https://api.reporter.nih.gov/v2/projects/search',
      body: %{{"criteria":{"org_names":["The Pennsylvania State University"]},"offset":0,"limit":1}},
      headers: { 'Content-Type' => 'application/json', 'accept' => 'application/json' }
    ).and_return single_project
    allow(HTTParty).to receive(:post).with(
      'https://api.reporter.nih.gov/v2/projects/search',
      body: %{{"criteria":{"org_names":["The Pennsylvania State University"]},"offset":0,"limit":500}},
      headers: { 'Content-Type' => 'application/json', 'accept' => 'application/json' }
    ).and_return projects_page_1
    allow(HTTParty).to receive(:post).with(
      'https://api.reporter.nih.gov/v2/projects/search',
      body: %{{"criteria":{"org_names":["The Pennsylvania State University"]},"offset":500,"limit":500}},
      headers: { 'Content-Type' => 'application/json', 'accept' => 'application/json' }
    ).and_return projects_page_2
    allow(HTTParty).to receive(:post).with(
      'https://api.reporter.nih.gov/v2/publications/search',
      body: %{{"criteria":{"core_project_nums":["abc123"]},"offset":0,"limit":500}},
      headers: { 'Content-Type' => 'application/json', 'accept' => 'application/json' }
    ).and_return publications
    allow(HTTParty).to receive(:get).with(
      'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=pm123'
    ).and_return pm_pub_1
    allow(HTTParty).to receive(:get).with(
      'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=pm456'
    ).and_return pm_pub_2
    allow(JSON).to receive(:parse).with('single project').and_return 'parsed single project'
    allow(JSON).to receive(:parse).with('projects page 1').and_return 'parsed projects page 1'
    allow(JSON).to receive(:parse).with('projects page 2').and_return 'parsed projects page 2'
    allow(JSON).to receive(:parse).with('publications').and_return({ 'results' => [{ 'pmid' => 'pm123' }, { 'pmid' => 'pm456' }] })
    allow(NIHProjects).to receive(:new).with('parsed single project').and_return(projects)
  end

  describe '#projects_pages_count' do
    context 'when the total number of NIH projects is 1' do
      it 'returns 1' do
        expect(client.projects_pages_count).to eq 1
      end
    end

    context 'when the total number of NIH projects is 500' do
      let(:projects_count) { 500 }

      it 'returns 1' do
        expect(client.projects_pages_count).to eq 1
      end
    end

    context 'when the total number of NIH projects is 501' do
      let(:projects_count) { 501 }

      it 'returns 2' do
        expect(client.projects_pages_count).to eq 2
      end
    end
  end

  describe '#projects' do
    context 'when given 1' do
      it 'returns the first page of projects' do
        expect(client.projects(1)).to eq 'parsed projects page 1'
      end
    end

    context 'when given 2' do
      it 'returns the second page of projects' do
        expect(client.projects(2)).to eq 'parsed projects page 2'
      end
    end
  end

  describe '#publications_by_project' do
    it 'returns the publication metadata from PubMed for the given NIH project number' do
      expect(client.publications_by_project('abc123')).to eq ['publication 1', 'publication 2']
    end
  end
end
