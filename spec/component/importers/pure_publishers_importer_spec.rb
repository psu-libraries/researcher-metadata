# frozen_string_literal: true

require 'component/component_spec_helper'
RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = 1000000000

describe PurePublishersImporter do
  let(:importer) { described_class.new }
  let(:found_pub_1) { Publisher.find_by(pure_uuid: '435826f4-a25d-4005-b9da-47d3507834ff') }
  let(:found_pub_2) { Publisher.find_by(pure_uuid: '24d7ee7c-7d06-4808-a3a0-8e9178f1da3f') }
  let(:http_response_1) { File.read(filename_1) }
  let(:http_response_2) { File.read(filename_2) }
  let(:http_error_response) { File.read(error_filename) }
  let(:filename_1) { Rails.root.join('spec', 'fixtures', 'pure_publishers_1.json') }
  let(:filename_2) { Rails.root.join('spec', 'fixtures', 'pure_publishers_2.json') }
  let(:error_filename) { Rails.root.join('spec', 'fixtures', 'pure_not_found_error.json') }

  before do
    allow(HTTParty).to receive(:get).with('https://pure.psu.edu/ws/api/524/publishers?navigationLink=false&size=1&offset=0',
                                          headers: { 'api-key' => 'fake_api_key', 'Accept' => 'application/json' }).and_return http_response_1

    allow(HTTParty).to receive(:get).with('https://pure.psu.edu/ws/api/524/publishers?navigationLink=false&size=1000&offset=0',
                                          headers: { 'api-key' => 'fake_api_key', 'Accept' => 'application/json' }).and_return http_response_2
  end

  describe '#call' do
    context 'when the API endpoint is found' do
      let(:email) { spy 'notification email' }

      before do
        allow(AdminNotificationsMailer).to receive(:pure_import_error).and_return email
      end

      it 'does not send a notification email to RMD admins' do
        importer.call
        expect(email).not_to have_received(:deliver_now)
      end

      context 'when no publishers already exist in the database' do
        it 'creates new publisher records for every publisher in the imported data' do
          expect { importer.call }.to change(Publisher, :count).by 2

          expect(found_pub_1.name).to eq 'Maik Nauka-Interperiodica Publishing'
          expect(found_pub_2.name).to eq 'Verlag Eugen Ulmer'
        end
      end

      context 'when a publisher matching the imported data already exists in the database' do
        let!(:existing_pub) { create(:publisher,
                                     pure_uuid: '435826f4-a25d-4005-b9da-47d3507834ff',
                                     name: 'existing name') }

        it 'creates new publisher records for every new publisher in the imported data and updates existing publishers' do
          expect { importer.call }.to change(Publisher, :count).by 1

          expect(existing_pub.reload.name).to eq 'Maik Nauka-Interperiodica Publishing'
          expect(found_pub_2.name).to eq 'Verlag Eugen Ulmer'
        end
      end
    end

    context 'when the API endpoint is not found' do
      let(:email) { spy 'notification email' }

      before do
        allow(HTTParty).to receive(:get).with('https://pure.psu.edu/ws/api/524/publishers?navigationLink=false&size=1&offset=0',
                                              headers: { 'api-key' => 'fake_api_key', 'Accept' => 'application/json' }).and_return http_error_response

        allow(HTTParty).to receive(:get).with('https://pure.psu.edu/ws/api/524/publishers?navigationLink=false&size=1000&offset=0',
                                              headers: { 'api-key' => 'fake_api_key', 'Accept' => 'application/json' }).and_return http_error_response

        allow(ImporterErrorLog).to receive(:log_error)
        allow(AdminNotificationsMailer).to receive(:pure_import_error).and_return email
      end

      it 'captures and logs the error' do
        importer.call

        expect(ImporterErrorLog).to have_received(:log_error).with(
          importer_class: described_class,
          error: an_instance_of(PureImporter::ServiceNotFound),
          metadata: {}
        )
      end

      it 'sends a notification email to RMD admins' do
        importer.call
        expect(email).to have_received(:deliver_now)
      end
    end

    context 'when there is an error within the loop' do
      before do
        allow(Publisher).to receive(:find_by).and_raise(ZeroDivisionError)

        allow(ImporterErrorLog).to receive(:log_error)
      end

      it 'logs the error and moves on' do
        importer.call

        expect(ImporterErrorLog).to have_received(:log_error).with(
          importer_class: described_class,
          error: an_instance_of(ZeroDivisionError),
          metadata: a_hash_including(
            publisher_id: nil,
            item: an_instance_of(Hash)
          )
        ).at_least(2).times
      end
    end
  end
end
