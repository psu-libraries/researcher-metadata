# frozen_string_literal: true

require 'component/component_spec_helper'

describe NSFGrantImporter do
  let(:importer) { described_class.new }

  describe '#call' do
    let!(:u1) { create(:user, first_name: 'Bethany', last_name: 'Testuser', webaccess_id: 'bat123') }
    let!(:u2) { create(:user, first_name: 'Jeff', last_name: 'Testresearcher', webaccess_id: 'jbt12') }

    let!(:pub1) { create(:publication, doi: 'https://doi.org/10.123/456') }
    let!(:pub2) { create(:publication, doi: 'https://doi.org/10.654/321') }
    let!(:pub3) { create(:publication, title: 'Test Award 3 Publication 1', published_on: Date.new(2026, 1, 1)) }

    let(:empty_response) { instance_double HTTParty::Response, body: '{"response": {"award": []}}' }
    let(:response) { instance_double HTTParty::Response, body: fixture_file_read('nsf_awards.json') }

    before do
      (1965..(Date.current.year - 1)).each do |year|
        allow(HTTParty).to receive(:get).with("https://api.nsf.gov/services/v1/awards.json?dateStart=01%2F01%2F#{year}&dateEnd=12%2F31%2F#{year}&rpp=3000&offset=0&awardeeName=%22Pennsylvania+State+Univ%22").and_return(empty_response)
      end

      allow(HTTParty).to receive(:get).with("https://api.nsf.gov/services/v1/awards.json?dateStart=01%2F01%2F#{Date.current.year}&dateEnd=12%2F31%2F#{Date.current.year}&rpp=3000&offset=0&awardeeName=%22Pennsylvania+State+Univ%22").and_return(response)
    end

    it 'creates new Grant records for each award in the imported data' do
      expect { importer.call }.to change(Grant, :count).by 3
    end

    it 'does not duplicate Grant records that already exist' do
      expect { 2.times { importer.call } }.to change(Grant, :count).by 3
    end

    it 'creates new ResearchFund records for each matching publication in the imported data' do
      expect { importer.call }.to change(ResearchFund, :count).by 3
    end

    it 'does not duplicate ResearcFund records that already exist' do
      expect { 2.times { importer.call } }.to change(ResearchFund, :count).by 3
    end

    it 'creates new ResearcherFund records for each matching researcher in the imported data' do
      expect { importer.call }.to change(ResearcherFund, :count).by 2
    end

    it 'does not duplicate ResearcherFund records that already exist' do
      expect { 2.times { importer.call } }.to change(ResearcherFund, :count).by 2
    end

    it 'populates the correct data in new records' do
      importer.call

      g1 = Grant.find_by(identifier: '8467351')
      g2 = Grant.find_by(identifier: '9710328')
      g3 = Grant.find_by(identifier: '7233491')

      expect(g1.title).to eq 'Test Award 1'
      expect(g1.start_date).to eq Date.new(2026, 1, 1)
      expect(g1.end_date).to eq Date.new(2027, 12, 31)
      expect(g1.abstract).to eq 'Test abstract 1'
      expect(g1.amount_in_dollars).to eq 98756
      expect(g1.agency_name).to eq 'National Science Foundation'

      expect(ResearchFund.find_by(grant: g1, publication: pub1)).not_to be_nil
      expect(ResearchFund.find_by(grant: g1, publication: pub2)).not_to be_nil
      expect(ResearcherFund.find_by(grant: g1, user: u1)).not_to be_nil

      expect(g2.title).to eq 'Test Award 2'
      expect(g2.start_date).to eq Date.new(2026, 2, 1)
      expect(g2.end_date).to eq Date.new(2026, 12, 31)
      expect(g2.abstract).to eq 'Test abstract 2'
      expect(g2.amount_in_dollars).to eq 50000
      expect(g2.agency_name).to eq 'National Science Foundation'

      expect(ResearcherFund.find_by(grant: g2, user: u2)).not_to be_nil

      expect(g3.title).to eq 'Test Award 3'
      expect(g3.start_date).to eq Date.new(2026, 3, 10)
      expect(g3.end_date).to eq Date.new(2027, 1, 1)
      expect(g3.abstract).to eq 'Test abstract 3'
      expect(g3.amount_in_dollars).to eq 100000
      expect(g3.agency_name).to eq 'National Science Foundation'

      expect(ResearchFund.find_by(grant: g3, publication: pub3)).not_to be_nil
    end

    context 'when a Grant that matches the imported data already exists' do
      let!(:existing_grant) {
        create(
          :grant,
          identifier: '8467351',
          agency_name: 'National Science Foundation',
          title: 'Existing Award',
          start_date: Date.new(2020, 7, 1),
          end_date: Date.new(2021, 6, 30),
          abstract: 'Existing abstract',
          amount_in_dollars: 40000
        )
      }

      it 'updates the data in the existing Grant' do
        importer.call
        g = existing_grant.reload

        expect(g.title).to eq 'Test Award 1'
        expect(g.start_date).to eq Date.new(2026, 1, 1)
        expect(g.end_date).to eq Date.new(2027, 12, 31)
        expect(g.abstract).to eq 'Test abstract 1'
        expect(g.amount_in_dollars).to eq 98756
        expect(g.agency_name).to eq 'National Science Foundation'
      end
    end
  end
end
