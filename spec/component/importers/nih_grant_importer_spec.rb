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

    it 'does not duplicate ResearchFund records that already exist' do
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

      expect(g1.agency_name).to eq 'NIH'
      expect(g1.title).to eq 'Test Research Proposal'
      expect(g1.start_date).to eq Date.new(2026, 3, 1)
      expect(g1.end_date).to eq Date.new(2027, 1, 31)
      expect(g1.abstract).to eq 'description of research'
      expect(g1.amount_in_dollars).to eq 425667
      expect(g1.import_source).to eq 'NIH'

      expect(ResearchFund.find_by(grant: g1, publication: pub_1, import_source: 'NIH')).not_to be_nil
      expect(ResearcherFund.find_by(grant: g1, user: user_1, import_source: 'NIH')).not_to be_nil

      expect(g2.agency_name).to eq 'FDA'
      expect(g2.title).to eq 'Another project'
      expect(g2.start_date).to eq Date.new(2020, 10, 15)
      expect(g2.end_date).to eq Date.new(2023, 1, 1)
      expect(g2.abstract).to eq 'another abstract'
      expect(g2.amount_in_dollars).to eq 104372
      expect(g2.import_source).to eq 'NIH'

      expect(ResearchFund.find_by(grant: g2, publication: pub_2, import_source: 'NIH')).not_to be_nil
      expect(ResearcherFund.find_by(grant: g2, user: user_2, import_source: 'NIH')).not_to be_nil
      expect(ResearcherFund.find_by(grant: g2, user: user_3, import_source: 'NIH')).not_to be_nil
    end

    context 'when a Grant that matches the imported data already exists' do
      let!(:existing_grant_1) {
        create(
          :grant,
          identifier: 'ABCD1234-01',
          agency_name: 'NSF',
          title: 'Existing Award 1',
          start_date: Date.new(2020, 7, 1),
          end_date: Date.new(2021, 6, 30),
          abstract: 'Existing abstract',
          amount_in_dollars: 40000,
          import_source: 'NSF'
        )
      }

      let!(:existing_grant_2) {
        create(
          :grant,
          identifier: 'ABCD1234-01',
          agency_name: 'NIH',
          title: 'Existing Award 2',
          start_date: Date.new(2020, 7, 1),
          end_date: Date.new(2021, 6, 30),
          abstract: 'Existing abstract',
          amount_in_dollars: 40000,
          import_source: 'NSF'
        )
      }

      it 'updates the data in the existing Grant' do
        importer.call
        g1 = existing_grant_1.reload
        g2 = existing_grant_2.reload

        expect(g1.title).to eq 'Existing Award 1'
        expect(g1.start_date).to eq Date.new(2020, 7, 1)
        expect(g1.end_date).to eq Date.new(2021, 6, 30)
        expect(g1.abstract).to eq 'Existing abstract'
        expect(g1.amount_in_dollars).to eq 40000
        expect(g1.agency_name).to eq 'NSF'
        expect(g1.import_source).to eq 'NSF'

        expect(g2.title).to eq 'Test Research Proposal'
        expect(g2.start_date).to eq Date.new(2026, 3, 1)
        expect(g2.end_date).to eq Date.new(2027, 1, 31)
        expect(g2.abstract).to eq 'description of research'
        expect(g2.amount_in_dollars).to eq 425667
        expect(g2.agency_name).to eq 'NIH'
        expect(g2.import_source).to eq 'NIH'
      end
    end

    context 'when an associated publication in the imported metadata is missing key information' do
      let(:publication_body_3) { fixture_file_read('nih/incomplete_publication_3.xml') }

      it 'creates new Grant records for each award in the imported data' do
        expect { importer.call }.to change(Grant, :count).by 2
      end

      it 'creates new ResearchFund records for each matching publication in the imported data with complete metadata' do
        expect { importer.call }.to change(ResearchFund, :count).by 1
      end

      it 'creates new ResearcherFund records for each matching researcher in the imported data' do
        expect { importer.call }.to change(ResearcherFund, :count).by 3
      end
    end
  end
end
