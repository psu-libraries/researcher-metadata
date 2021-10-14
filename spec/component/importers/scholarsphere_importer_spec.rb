# frozen_string_literal: true

require 'component/component_spec_helper'

describe ScholarsphereImporter do
  let(:importer) { described_class.new }

  describe '#call' do
    let(:response) { double 'HTTParty response', body: json_data }
    let(:json_data) { fixture_file_open('scholarsphere_dois.json').read }

    before do
      allow(Rails).to receive_message_chain(
        :application, :config, :x, :scholarsphere, :[]
      ).with('SS4_ENDPOINT').and_return 'https://scholarsphere.test/api/'
      allow(Rails).to receive_message_chain(
        :application, :config, :x, :scholarsphere, :[]
      ).with('SS_CLIENT_KEY').and_return 'secret_key'
      allow(HTTParty).to receive(:get).with('https://scholarsphere.test/api/dois',
                                            headers: { 'X-API-KEY' => 'secret_key' }).and_return(response)
      allow(ResearcherMetadata::Application).to receive(:scholarsphere_base_uri).and_return 'https://scholarsphere.test'
    end

    context 'when a publication exists in the database that matches an incoming DOI' do
      let!(:pub) { create :publication,
                          doi: 'https://doi.org/10.1109/5.771073' }

      context 'when the publication already has an open access location that matches a URL from ScholarSphere' do
        let!(:oal) { create :open_access_location,
                            source: 'ScholarSphere',
                            publication: pub,
                            url: 'https://scholarsphere.test/resources/67b85129-8431-494a-8a3e-a8d07cd350bc'}

        it 'only creates new open access locations for new URLs from ScholarSphere' do
          expect { importer.call }.to change(OpenAccessLocation, :count).by 2
          expect(pub.open_access_locations.find_by(
                   source: 'ScholarSphere',
                   url: 'https://scholarsphere.test/resources/0b591fea-7bef-4e06-9554-6417bf2c040e'
                 )).not_to be_nil
          expect(pub.open_access_locations.find_by(
                   source: 'ScholarSphere',
                   url: 'https://scholarsphere.test/resources/21dd75c1-65c8-49ba-959a-9443ab27dc16'
                 )).not_to be_nil
        end
      end
    end
  end
end
