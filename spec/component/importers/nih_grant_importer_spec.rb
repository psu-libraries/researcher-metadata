# frozen_string_literal: true

require 'component/component_spec_helper'

describe NIHGrantImporter do
  let(:importer) { described_class }
  let(:projects_response) { instance_double HTTParty::Response, body: projects_body }
  let(:publications_response_1) { instance_double HTTParty::Response, body: publications_body_1 }
  let(:publications_response_2) { instance_double HTTParty::Response, body: publications_body_2 }
  let(:publication_response_1) { instance_double HTTParty::Response, body: publication_body_1 }
  let(:publication_response_2) { instance_double HTTParty::Response, body: publication_body_2 }
  let(:publication_response_3) { instance_double HTTParty::Response, body: publication_body_3 }
  let(:projects_body) { fixture_file_read('nih/projects.json') }
  let(:publications_body_1) { fixture_file_read('nih/publications_1.json') }
  let(:publications_body_2) { fixture_file_read('nih/publications_2.json') }
  let(:publication_body_1) { fixture_file_read('nih/publication_1.xml') }
  let(:publication_body_2) { fixture_file_read('nih/publication_2.xml') }
  let(:publication_body_3) { fixture_file_read('nih/publication_3.xml') }
  let!(:user_1) { create(:user, first_name: 'Test', middle_name: 'S', last_name: 'Researcher') }
  let!(:user_2) { create(:user, first_name: 'Another', middle_name: 'Test', last_name: 'Scientist') }
  let!(:user_3) { create(:user, first_name: 'Third', middle_name: 'Bartholomew', last_name: 'Testperson') }
  let!(:pub_1) { create(:publication, doi: 'https://doi.org/10.1234/abc123') }
  let!(:pub_2) { create(:publication, title: 'Third Test Publication', published_on: Date.new(2025, 6, 1)) }

  before do
    allow(HTTParty).to receive(:post).with(
      'https://api.reporter.nih.gov/v2/projects/search',
      body: '{"criteria":{"org_names":["The Pennsylvania State University"]},"offset":0,"limit":1}',
      headers: { 'Content-Type' => 'application/json', 'accept' => 'application/json' }
    ).and_return projects_response

    allow(HTTParty).to receive(:post).with(
      'https://api.reporter.nih.gov/v2/projects/search',
      body: '{"criteria":{"org_names":["The Pennsylvania State University"]},"offset":0,"limit":500}',
      headers: { 'Content-Type' => 'application/json', 'accept' => 'application/json' }
    ).and_return projects_response

    allow(HTTParty).to receive(:post).with(
      'https://api.reporter.nih.gov/v2/publications/search',
      body: '{"criteria":{"core_project_nums":["ABCD1234"]},"offset":0,"limit":500}',
      headers: { 'Content-Type' => 'application/json', 'accept' => 'application/json' }
    ).and_return publications_response_1

    allow(HTTParty).to receive(:post).with(
      'https://api.reporter.nih.gov/v2/publications/search',
      body: '{"criteria":{"core_project_nums":["WXYZ6789"]},"offset":0,"limit":500}',
      headers: { 'Content-Type' => 'application/json', 'accept' => 'application/json' }
    ).and_return publications_response_2

    allow(HTTParty).to receive(:get).with(
      'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=23463467'
    ).and_return publication_response_1

    allow(HTTParty).to receive(:get).with(
      'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=72895458'
    ).and_return publication_response_2

    allow(HTTParty).to receive(:get).with(
      'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=39684784'
    ).and_return publication_response_3
  end

  describe '#call' do
    it 'creates new Grant records for each award in the imported data' do
      expect { importer.call }.to change(Grant, :count).by 2
    end

    it 'does not duplicate Grant records that already exist' do
      expect { 2.times { importer.call } }.to change(Grant, :count).by 2
    end

    it 'creates new ResearchFund records for each matching publication in the imported data' do
      expect { importer.call }.to change(ResearchFund, :count).by 2
    end

    it 'does not duplicate ResearcFund records that already exist' do
      expect { 2.times { importer.call } }.to change(ResearchFund, :count).by 2
    end

    it 'creates new ResearcherFund records for each matching researcher in the imported data' do
      expect { importer.call }.to change(ResearcherFund, :count).by 3
    end

    it 'does not duplicate ResearcherFund records that already exist' do
      expect { 2.times { importer.call } }.to change(ResearcherFund, :count).by 3
    end

    it 'populates the correct data in new records' do
      importer.call

      g1 = Grant.find_by(identifier: 'ABCD1234-01')
      g2 = Grant.find_by(identifier: 'WXYZ6789-02')

      expect(g1).not_to be_nil
      expect(g2).not_to be_nil
    end
  end
end
