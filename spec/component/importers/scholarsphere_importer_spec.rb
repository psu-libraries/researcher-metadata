# frozen_string_literal: true

require 'component/component_spec_helper'

describe ScholarsphereImporter do
  let(:importer) { described_class.new }

  describe '#call' do
    let(:response) { double 'HTTParty response', body: json_data }
    let(:json_data) { fixture_file_open('scholarsphere_dois.json').read }

    before do
      allow(HTTParty).to receive(:get).with('https://scholarsphere.test/api/dois',
                                            headers: { 'X-API-KEY' => 'secret_key' }).and_return(response)
      allow(ResearcherMetadata::Application).to receive(:scholarsphere_base_uri).and_return 'https://scholarsphere.test'
    end

    context 'when a publications exist in the database that match an incoming DOI' do
      let!(:pub1) { create(:publication,
                           doi: 'https://doi.org/10.1109/5.771073') }
      let!(:pub2) { create(:publication,
                           doi: 'https://doi.org/10.1109/5.771073') }

      context 'when one of the publications already has an open access location that matches a URL from ScholarSphere' do
        let!(:oal) { create(:open_access_location,
                            source: Source::SCHOLARSPHERE,
                            publication: pub1,
                            url: 'https://scholarsphere.test/resources/67b85129-8431-494a-8a3e-a8d07cd350bc')}

        it 'creates new open access locations only for new URLs from ScholarSphere for each publication' do
          expect { importer.call }.to change(OpenAccessLocation, :count).by 5
          expect(pub1.open_access_locations.find_by(
                   source: Source::SCHOLARSPHERE,
                   url: 'https://scholarsphere.test/resources/0b591fea-7bef-4e06-9554-6417bf2c040e'
                 )).not_to be_nil
          expect(pub1.open_access_locations.find_by(
                   source: Source::SCHOLARSPHERE,
                   url: 'https://scholarsphere.test/resources/21dd75c1-65c8-49ba-959a-9443ab27dc16'
                 )).not_to be_nil

          expect(pub2.open_access_locations.find_by(
                   source: Source::SCHOLARSPHERE,
                   url: 'https://scholarsphere.test/resources/0b591fea-7bef-4e06-9554-6417bf2c040e'
                 )).not_to be_nil
          expect(pub2.open_access_locations.find_by(
                   source: Source::SCHOLARSPHERE,
                   url: 'https://scholarsphere.test/resources/67b85129-8431-494a-8a3e-a8d07cd350bc'
                 )).not_to be_nil
          expect(pub2.open_access_locations.find_by(
                   source: Source::SCHOLARSPHERE,
                   url: 'https://scholarsphere.test/resources/21dd75c1-65c8-49ba-959a-9443ab27dc16'
                 )).not_to be_nil
        end
      end
    end

    context 'when the API endpoint is not found' do
      before do
        allow(HTTParty).to receive(:get).with('https://scholarsphere.test/api/dois',
                                              headers: { 'X-API-KEY' => 'secret_key' }).and_raise(SocketError)

        allow(ImporterErrorLog).to receive(:log_error)
      end

      it 'captures and logs the error' do
        importer.call

        expect(ImporterErrorLog).to have_received(:log_error).with(
          importer_class: described_class,
          error: an_instance_of(SocketError),
          metadata: {}
        )
      end
    end

    context 'when there is an error within the loop' do
      before do
        allow(Publication).to receive(:where).and_raise(ZeroDivisionError)

        allow(ImporterErrorLog).to receive(:log_error)
      end

      it 'logs the error and moves on' do
        importer.call

        expect(ImporterErrorLog).to have_received(:log_error).with(
          importer_class: described_class,
          error: an_instance_of(ZeroDivisionError),
          metadata: a_hash_including(
            k: an_instance_of(String),
            v: an_instance_of(Array),
            matching_pub_ids: nil
          )
        ).at_least(2).times
      end
    end

    context 'when there is an error within the inner loop' do
      let!(:pub) { create(:publication,
                          doi: 'https://doi.org/10.1016/j.scitotenv.2021.145145',
                          open_access_locations: []) }

      before do
        allow(ActiveRecord::Base).to receive(:transaction).and_raise(ZeroDivisionError)

        allow(ImporterErrorLog).to receive(:log_error)
      end

      it 'logs the error and moves on' do
        importer.call

        expect(ImporterErrorLog).to have_received(:log_error).with(
          importer_class: described_class,
          error: an_instance_of(ZeroDivisionError),
          metadata: a_hash_including(
            k: an_instance_of(String),
            v: an_instance_of(Array),
            publication_id: pub.id
          )
        )
      end
    end
  end
end
