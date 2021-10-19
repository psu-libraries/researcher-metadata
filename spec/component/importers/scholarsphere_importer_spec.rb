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
                          doi: 'https://doi.org/10.1016/j.scitotenv.2021.145145',
                          scholarsphere_open_access_url: url }
      let!(:auth1) { create :authorship, publication: pub }
      let!(:auth2) { create :authorship, publication: pub }
      let(:url) { '' }

      context 'when the publication already has a ScholarSphere open access URL' do
        let(:url) { 'a_url' }

        it 'does not update the URL' do
          importer.call
          expect(pub.reload.scholarsphere_open_access_url).to eq 'a_url'
        end
      end

      context 'when the publication does not already have a ScholarSphere open access URL' do
        it "updates the publication with the first ScholarSphere URL listed for the publication's DOI" do
          importer.call
          expect(pub.reload.scholarsphere_open_access_url).to eq 'https://scholarsphere.test/resources/cd1542ae-087d-4f32-b920-5a7faaab63ac'
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
      let!(:pub) { create :publication,
                          doi: 'https://doi.org/10.1016/j.scitotenv.2021.145145',
                          scholarsphere_open_access_url: url }
      let(:url) { '' }

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
