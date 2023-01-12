# frozen_string_literal: true

require 'component/component_spec_helper'

describe PureUserImporter do
  let(:importer) { described_class.new }
  let(:http_response_1) { File.read(filename_1) }
  let(:http_response_2) { File.read(filename_2) }
  let(:http_error_response) { File.read(error_filename) }
  let(:filename_1) { Rails.root.join('spec', 'fixtures', 'pure_users_1.json') }
  let(:filename_2) { Rails.root.join('spec', 'fixtures', 'pure_users_2.json') }
  let(:error_filename) { Rails.root.join('spec', 'fixtures', 'pure_not_found_error.json') }

  before do
    allow(HTTParty).to receive(:get).with('https://pennstate.pure.elsevier.com/ws/api/523/persons?navigationLink=false&size=1&offset=0',
                                          headers: { 'api-key' => 'fake_api_key', 'Accept' => 'application/json' }).and_return http_response_1

    allow(HTTParty).to receive(:get).with('https://pennstate.pure.elsevier.com/ws/api/523/persons?navigationLink=false&size=100&offset=0',
                                          headers: { 'api-key' => 'fake_api_key', 'Accept' => 'application/json' }).and_return http_response_2
  end

  describe '#call' do
    context 'when the API endpoint is found' do
      context 'when no user records exist in the database' do
        it 'creates a new user record for each user object in the imported data' do
          expect { importer.call }.to change(User, :count).by 3

          u1 = User.find_by(webaccess_id: 'sat1')
          u2 = User.find_by(webaccess_id: 'bbt2')
          u3 = User.find_by(webaccess_id: 'jct3')

          expect(u1.first_name).to eq 'Susan'
          expect(u1.middle_name).to eq 'A'
          expect(u1.last_name).to eq 'Tester'
          expect(u1.pure_uuid).to eq '9530a014-c29f-4081-88ae-b923dc919001'
          expect(u1.scopus_h_index).to eq 15

          expect(u2.first_name).to eq 'Bob'
          expect(u2.middle_name).to eq 'B'
          expect(u2.last_name).to eq 'Testuser'
          expect(u2.pure_uuid).to eq 'a9ea5e62-9b39-4281-a759-e1c58f0ec582'
          expect(u2.scopus_h_index).to eq 21

          expect(u3.first_name).to eq 'Jill'
          expect(u3.middle_name).to be_nil
          expect(u3.last_name).to eq 'Test'
          expect(u3.pure_uuid).to eq '0177f1b1-bf3c-4f8d-af2a-10fe0034754c'
          expect(u3.scopus_h_index).to eq 2
        end

        context 'when no organizations exist in the database' do
          it 'does not create any new organization memberships' do
            expect { importer.call }.not_to change(UserOrganizationMembership, :count)
          end
        end

        context 'when organizations that are referenced in the imported data exist in the database' do
          let!(:org1) { create(:organization, pure_uuid: '937d604c-a16a-499d-80eb-bd6f931a343c') }
          let!(:org2) { create(:organization, pure_uuid: 'e99fcbec-818a-4b90-a04a-986d05696395') }
          let!(:org3) { create(:organization, pure_uuid: '47bf26c5-18c0-45d1-8aab-9f4597321764') }

          context 'when no organization memberships already exist' do
            it 'creates a new membership for each association described in the imported data' do
              expect { importer.call }.to change(UserOrganizationMembership, :count).by 3

              u1 = User.find_by(webaccess_id: 'sat1')
              u2 = User.find_by(webaccess_id: 'bbt2')

              m1 = UserOrganizationMembership.find_by(source_identifier: '21279128', import_source: 'Pure')
              m2 = UserOrganizationMembership.find_by(source_identifier: '21309545', import_source: 'Pure')
              m3 = UserOrganizationMembership.find_by(source_identifier: '24766061', import_source: 'Pure')

              expect(m1.user).to eq u1
              expect(m1.organization).to eq org1
              expect(m1.primary).to be false
              expect(m1.position_title).to eq 'Associate Professor'
              expect(m1.started_on).to eq Date.new(1984, 8, 14)
              expect(m1.ended_on).to eq Date.new(1990, 8, 14)
              expect(m1.updated_by_user_at).to be_nil

              expect(m2.user).to eq u2
              expect(m2.organization).to eq org2
              expect(m2.primary).to be false
              expect(m2.position_title).to eq 'Professor'
              expect(m2.started_on).to eq Date.new(1997, 9, 1)
              expect(m2.ended_on).to eq Date.new(2000, 1, 1)
              expect(m2.updated_by_user_at).to be_nil

              expect(m3.user).to eq u2
              expect(m3.organization).to eq org3
              expect(m3.primary).to be false
              expect(m3.position_title).to eq 'Senior Associate Dean'
              expect(m3.started_on).to eq Date.new(1997, 9, 1)
              expect(m3.ended_on).to be_nil
              expect(m3.updated_by_user_at).to be_nil
            end
          end

          context 'when organization memberships already exist for associations described in the imported data' do
            let!(:existing_membership1) { create(:user_organization_membership,
                                                 import_source: 'Pure',
                                                 source_identifier: '24766061',
                                                 user: other_user,
                                                 organization: other_org,
                                                 primary: true,
                                                 position_title: 'Existing Title',
                                                 started_on: Date.new(1900, 1, 1),
                                                 ended_on: Date.new(2000, 1, 1)) }
            let!(:existing_membership2) { create(:user_organization_membership,
                                                 import_source: nil,
                                                 source_identifier: '21279128',
                                                 user: other_user,
                                                 organization: other_org,
                                                 primary: true,
                                                 position_title: 'Existing Title 2',
                                                 started_on: Date.new(1900, 1, 1),
                                                 ended_on: Date.new(2000, 1, 1)) }
            let!(:existing_membership3) { create(:user_organization_membership,
                                                 import_source: 'HR',
                                                 source_identifier: nil,
                                                 user: user2,
                                                 organization: org2,
                                                 primary: nil,
                                                 position_title: 'Existing Title 3',
                                                 started_on: Date.new(1997, 9, 1),
                                                 ended_on: Date.new(2000, 1, 1)) }
            let!(:user1) { create(:user, webaccess_id: 'sat1') }
            let!(:user2) { create(:user, webaccess_id: 'bbt2') }
            let(:other_user) { create(:user) }
            let(:other_org) { create(:organization) }

            it 'creates a new membership for each new association and updates the existing memberships' do
              expect { importer.call }.to change(UserOrganizationMembership, :count).by 1

              m1 = UserOrganizationMembership.find_by(source_identifier: '21279128', import_source: 'Pure')
              m2 = existing_membership3.reload
              m3 = existing_membership1.reload
              m4 = existing_membership2.reload

              # This membership was created from the data in the import.
              expect(m1.user).to eq user1
              expect(m1.organization).to eq org1
              expect(m1.primary).to be false
              expect(m1.position_title).to eq 'Associate Professor'
              expect(m1.started_on).to eq Date.new(1984, 8, 14)
              expect(m1.ended_on).to eq Date.new(1990, 8, 14)
              expect(m1.updated_by_user_at).to be_nil

              # A membership with a matching user, organization, and start date had already
              # been imported from HR data, so overwrite it with the data from Pure
              expect(m2.import_source).to eq 'Pure'
              expect(m2.source_identifier).to eq '21309545'
              expect(m2.user).to eq user2
              expect(m2.organization).to eq org2
              expect(m2.primary).to be false
              expect(m2.position_title).to eq 'Professor'
              expect(m2.started_on).to eq Date.new(1997, 9, 1)
              expect(m2.ended_on).to eq Date.new(2000, 1, 1)
              expect(m2.updated_by_user_at).to be_nil

              # A membership with this Pure identifier already existed with different
              # data than the data in the import, so it was updated with the data in
              # the import.
              expect(m3.user).to eq user2
              expect(m3.organization).to eq org3
              expect(m3.primary).to be false
              expect(m3.position_title).to eq 'Senior Associate Dean'
              expect(m3.started_on).to eq Date.new(1997, 9, 1)
              expect(m3.ended_on).to be_nil
              expect(m3.updated_by_user_at).to be_nil

              # This membership has the same source identifier as one of the Pure memberships
              # that is being imported, but it does not list Pure as the import source, so it
              # should not be updated.
              expect(m4.import_source).to be_nil
              expect(m4.source_identifier).to eq '21279128'
              expect(m4.user).to eq other_user
              expect(m4.organization).to eq other_org
              expect(m4.primary).to be true
              expect(m4.position_title).to eq 'Existing Title 2'
              expect(m4.started_on).to eq Date.new(1900, 1, 1)
              expect(m4.ended_on).to eq Date.new(2000, 1, 1)
              expect(m4.updated_by_user_at).to be_nil
            end
          end
        end
      end

      context 'when a user in the imported data already exists in the database' do
        let!(:existing_user) { create(:user,
                                      webaccess_id: 'bbt2',
                                      first_name: 'Robert',
                                      middle_name: 'B',
                                      last_name: 'Testuser',
                                      penn_state_identifier: '987654321',
                                      pure_uuid: '12345678',
                                      scopus_h_index: 79) }

        it 'creates new records for the new users and does not update user data for existing records' do
          expect { importer.call }.to change(User, :count).by 2

          u1 = User.find_by(webaccess_id: 'sat1')
          u2 = User.find_by(webaccess_id: 'bbt2')
          u3 = User.find_by(webaccess_id: 'jct3')

          expect(u1.first_name).to eq 'Susan'
          expect(u1.middle_name).to eq 'A'
          expect(u1.last_name).to eq 'Tester'
          expect(u1.pure_uuid).to eq '9530a014-c29f-4081-88ae-b923dc919001'
          expect(u1.scopus_h_index).to eq 15

          expect(u2.first_name).to eq 'Robert'
          expect(u2.middle_name).to eq 'B'
          expect(u2.last_name).to eq 'Testuser'
          expect(u2.pure_uuid).to eq 'a9ea5e62-9b39-4281-a759-e1c58f0ec582'
          expect(u2.scopus_h_index).to eq 21

          expect(u3.first_name).to eq 'Jill'
          expect(u3.middle_name).to be_nil
          expect(u3.last_name).to eq 'Test'
          expect(u3.pure_uuid).to eq '0177f1b1-bf3c-4f8d-af2a-10fe0034754c'
          expect(u3.scopus_h_index).to eq 2
        end
      end
    end

    context 'when the API endpoint is not found' do
      before do
        allow(HTTParty).to receive(:get).with('https://pennstate.pure.elsevier.com/ws/api/523/persons?navigationLink=false&size=1&offset=0',
                                              headers: { 'api-key' => 'fake_api_key', 'Accept' => 'application/json' }).and_return http_error_response

        allow(HTTParty).to receive(:get).with('https://pennstate.pure.elsevier.com/ws/api/523/persons?navigationLink=false&size=100&offset=0',
                                              headers: { 'api-key' => 'fake_api_key', 'Accept' => 'application/json' }).and_return http_error_response

        allow(ImporterErrorLog).to receive(:log_error)
      end

      it 'captures and logs the error' do
        importer.call

        expect(ImporterErrorLog).to have_received(:log_error).with(
          importer_class: described_class,
          error: an_instance_of(PureImporter::ServiceNotFound),
          metadata: {}
        )
      end
    end

    context 'when there is an error within the loop' do
      before do
        allow(User).to receive(:find_by).and_raise(ZeroDivisionError)

        allow(ImporterErrorLog).to receive(:log_error)
      end

      it 'logs the error and moves on' do
        importer.call

        expect(ImporterErrorLog).to have_received(:log_error).with(
          importer_class: described_class,
          error: an_instance_of(ZeroDivisionError),
          metadata: a_hash_including(
            user_id: nil,
            item: an_instance_of(Hash)
          )
        ).at_least(2).times
      end
    end
  end
end
