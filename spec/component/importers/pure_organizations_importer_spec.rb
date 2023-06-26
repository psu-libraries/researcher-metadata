# frozen_string_literal: true

require 'component/component_spec_helper'

describe PureOrganizationsImporter do
  let(:importer) { described_class.new }
  let(:http_response_1) { File.read(filename_1) }
  let(:http_response_2) { File.read(filename_2) }
  let(:http_error_response) { File.read(error_filename) }
  let(:filename_1) { Rails.root.join('spec', 'fixtures', 'pure_organizations_1.json') }
  let(:filename_2) { Rails.root.join('spec', 'fixtures', 'pure_organizations_2.json') }
  let(:error_filename) { Rails.root.join('spec', 'fixtures', 'pure_not_found_error.json') }

  before do
    allow(HTTParty).to receive(:get).with('https://pennstate.pure.elsevier.com/ws/api/524/organisational-units?navigationLink=false&size=1&offset=0',
                                          headers: { 'api-key' => 'fake_api_key', 'Accept' => 'application/json' }).and_return http_response_1

    allow(HTTParty).to receive(:get).with('https://pennstate.pure.elsevier.com/ws/api/524/organisational-units?navigationLink=false&size=1000&offset=0',
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

      context 'when no organizations exist in the database' do
        it 'creates new organization records for every organization in the imported data' do
          expect { importer.call }.to change(Organization, :count).by 3

          o1 = Organization.find_by(pure_uuid: 'pure-uuid-001')
          o2 = Organization.find_by(pure_uuid: 'pure-uuid-002')
          o3 = Organization.find_by(pure_uuid: 'pure-uuid-003')

          expect(o1.name).to eq 'Biology'
          expect(o1.pure_external_identifier).to eq 'EXT-ID-1'
          expect(o1.organization_type).to eq 'Department'
          expect(o1.parent).to eq o2

          expect(o2.name).to eq 'College of Science'
          expect(o2.pure_external_identifier).to eq 'EXT-ID-2'
          expect(o2.organization_type).to eq 'College'
          expect(o2.parent).to be_nil

          expect(o3.name).to eq 'College of Nursing'
          expect(o3.pure_external_identifier).to eq 'EXT-ID-3'
          expect(o3.organization_type).to eq 'College'
          expect(o3.parent).to be_nil
        end
      end

      context 'when an organization matching the imported data already exists in the database' do
        before do
          create(:organization,
                 name: 'existing name',
                 pure_uuid: 'pure-uuid-002',
                 pure_external_identifier: 'existing id',
                 organization_type: 'existing type',
                 parent: create(:organization, pure_uuid: 'something'))
        end

        it 'creates new organization records for every new organization in the imported data and updates existing organizations' do
          expect { importer.call }.to change(Organization, :count).by 2

          o1 = Organization.find_by(pure_uuid: 'pure-uuid-001')
          o2 = Organization.find_by(pure_uuid: 'pure-uuid-002')
          o3 = Organization.find_by(pure_uuid: 'pure-uuid-003')

          expect(o1.name).to eq 'Biology'
          expect(o1.pure_external_identifier).to eq 'EXT-ID-1'
          expect(o1.organization_type).to eq 'Department'
          expect(o1.parent).to eq o2

          expect(o2.name).to eq 'College of Science'
          expect(o2.pure_external_identifier).to eq 'EXT-ID-2'
          expect(o2.organization_type).to eq 'College'
          expect(o2.parent).to be_nil

          expect(o3.name).to eq 'College of Nursing'
          expect(o3.pure_external_identifier).to eq 'EXT-ID-3'
          expect(o3.organization_type).to eq 'College'
          expect(o3.parent).to be_nil
        end
      end
    end

    context 'when the API endpoint is not found' do
      let(:email) { spy 'notification email' }

      before do
        allow(HTTParty).to receive(:get).with('https://pennstate.pure.elsevier.com/ws/api/524/organisational-units?navigationLink=false&size=1&offset=0',
                                              headers: { 'api-key' => 'fake_api_key', 'Accept' => 'application/json' }).and_return http_error_response

        allow(HTTParty).to receive(:get).with('https://pennstate.pure.elsevier.com/ws/api/524/organisational-units?navigationLink=false&size=1000&offset=0',
                                              headers: { 'api-key' => 'fake_api_key', 'Accept' => 'application/json' }).and_return http_error_response

        allow(ImporterErrorLog).to receive(:log_error)
        allow(AdminNotificationsMailer).to receive(:pure_import_error).and_return email
      end

      it 'reports an error' do
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

    context 'when there is a problem inside one of the loops' do
      before do
        allow(Organization).to receive(:find_by).and_raise(ZeroDivisionError)

        allow(ImporterErrorLog).to receive(:log_error)
      end

      it 'reports an error and moves on to the next iteration' do
        importer.call

        expect(ImporterErrorLog).to have_received(:log_error).with(
          importer_class: described_class,
          error: an_instance_of(ZeroDivisionError),
          metadata: anything
        ).at_least(2).times

        expect(ImporterErrorLog).to have_received(:log_error).with(
          importer_class: described_class,
          error: an_instance_of(ZeroDivisionError),
          metadata: a_hash_including(
            organization_id: nil,
            item: an_instance_of(Hash)
          )
        ).at_least(1).times

        expect(ImporterErrorLog).to have_received(:log_error).with(
          importer_class: described_class,
          error: an_instance_of(ZeroDivisionError),
          metadata: a_hash_including(
            child_org_id: nil,
            parent_org_id: nil,
            item: an_instance_of(Hash)
          )
        ).at_least(1).times
      end
    end
  end
end
