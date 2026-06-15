# frozen_string_literal: true

require 'component/component_spec_helper'

describe OpenAlexDatasetImporter do
  describe '.call' do
    let(:settings) { double 'Open Alex settings', api_key: 'open-alex-key' }
    let(:oa_response_1) { instance_double(HTTParty::Response, body: fixture_file_read('open_alex_datasets_1.json')) }
    let(:oa_response_2) { instance_double(HTTParty::Response, body: fixture_file_read('open_alex_datasets_2.json')) }

    before do
      allow(Settings).to receive(:open_alex).and_return settings
      allow(HTTParty).to receive(:get).with('https://api.openalex.org/works?filter=institutions.id:I130769515,type:dataset&per_page=100&cursor=*&api_key=open-alex-key').and_return(oa_response_1)
      allow(HTTParty).to receive(:get).with('https://api.openalex.org/works?filter=institutions.id:I130769515,type:dataset&per_page=100&cursor=cursor_abc123&api_key=open-alex-key').and_return(oa_response_2)
    end

    it 'creates a new Publication record for every published Penn State dataset in the Open Alex metadata' do
      expect { described_class.call }.to change(Publication, :count).by 3
    end

    it 'creates a new PublicationImport record for every published Penn State dataset in the Open Alex metadata' do
      expect { described_class.call }.to change(PublicationImport, :count).by 3
    end

    it 'saves the correct data in the new records' do
      described_class.call

      import_1 = PublicationImport.find_by(source: 'Open Alex', source_identifier: 'open-alex-id-1')
      p1 = import_1.publication

      expect(import_1.source_updated_at).to be_within(1.second).of(Time.new(2026, 6, 2, 9, 4, 35.204637))
      expect(p1.doi).to eq 'https://doi.org/10.1/a'
      expect(p1.title).to eq 'Test Dataset 1'
      expect(p1.publication_type).to eq 'Dataset'
      expect(p1.status).to eq 'Published'
      expect(p1.published_on).to eq Date.new(2026, 5, 10)
      expect(p1.open_access_status).to eq 'green'
      expect(p1.publisher_name).to eq 'Test Repo 1'

      import_2 = PublicationImport.find_by(source: 'Open Alex', source_identifier: 'open-alex-id-2')
      p2 = import_2.publication

      expect(import_2.source_updated_at).to be_within(1.second).of(Time.new(2026, 2, 1, 10, 17, 42.837655))
      expect(p2.doi).to eq 'https://doi.org/10.2/b'
      expect(p2.title).to eq 'Test Dataset 2'
      expect(p2.publication_type).to eq 'Dataset'
      expect(p2.status).to eq 'Published'
      expect(p2.published_on).to eq Date.new(2020, 1, 1)
      expect(p2.open_access_status).to eq 'bronze'
      expect(p2.publisher_name).to eq 'Test Repo 2'

      import_3 = PublicationImport.find_by(source: 'Open Alex', source_identifier: 'open-alex-id-4')
      p3 = import_3.publication

      expect(import_3.source_updated_at).to be_within(1.second).of(Time.new(2025, 12, 18, 1, 6, 22.538611))
      expect(p3.doi).to eq 'https://doi.org/10.4/d'
      expect(p3.title).to eq 'Test Dataset 4'
      expect(p3.publication_type).to eq 'Dataset'
      expect(p3.status).to eq 'Published'
      expect(p3.published_on).to eq Date.new(2021, 10, 7)
      expect(p3.open_access_status).to eq 'unknown'
      expect(p3.publisher_name).to eq 'Test Repo 4'
    end

    context 'when a PublicationImport record already exists for a dataset in the Open Alex metadata' do
      before { create(:publication_import, source: 'Open Alex', source_identifier: 'open-alex-id-1') }

      it 'does not create a new Publication record for the existing dataset' do
        expect { described_class.call }.to change(Publication, :count).by 2
      end

      it 'does not create a new PublicationImport record for the existing dataset' do
        expect { described_class.call }.to change(PublicationImport, :count).by 2
      end
    end
  end
end
