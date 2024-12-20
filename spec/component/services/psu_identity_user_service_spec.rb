# frozen_string_literal: true

require 'component/component_spec_helper'

describe PSUIdentityUserService, :vcr do
  # Note this spec uses VCR to mock HTTP requests to the actual PSU identity
  # server. If you change this value, you will will invalidate the VCR
  # cassettes and send new requests.
  let(:webaccess_id) { 'abc123' }

  describe '.find_or_initialize_user' do
    subject(:call) { described_class.find_or_initialize_user(webaccess_id: webaccess_id) }

    context 'when the User exists in the database' do
      let!(:user) do
        create(:user, webaccess_id: webaccess_id,
                      first_name: 'FName',
                      last_name: 'LName',
                      middle_name: 'MName')
      end

      context 'when identity data is found' do
        it 'returns the User updated with data from PsuIdentity' do
          expect(call).to eq user
          user.reload
          expect(user.first_name).to eq 'Firstname'
          expect(user.middle_name).to eq 'Middlename'
          expect(user.last_name).to eq 'Lastname'
          expect(user.psu_identity.present?).to be true
        end
      end

      context 'when no identity data is found' do
        it 'returns the User without updated identity data' do
          expect(call).to eq user
          user.reload
          expect(user.first_name).to eq 'FName'
          expect(user.middle_name).to eq 'MName'
          expect(user.last_name).to eq 'LName'
          expect(user.psu_identity.present?).to be false
        end
      end
    end

    context 'when no User exists in the database' do
      context 'when all is well with PsuIdentity' do
        let(:user) { call }

        context 'when the user in PsuIdentity has no preferred names' do
          it 'returns a User initialized with data from PsuIdentity' do
            # Note this relies on an edited VCR cassette
            expect(user.webaccess_id).to eq webaccess_id
            expect(user.first_name).to eq 'Firstname'
            expect(user.middle_name).to eq 'Middlename'
            expect(user.last_name).to eq 'Lastname'
            expect(user.psu_identity).to be_an_instance_of(PsuIdentity::SearchService::Person)
            expect(user.psu_identity_updated_at).to be_within(2.seconds).of(Time.zone.now)
          end
        end

        context 'when the user in PsuIdentity has preferred names' do
          it 'returns a User initialized with data from PsuIdentity' do
            # Note this relies on an edited VCR cassette
            expect(user.webaccess_id).to eq webaccess_id
            expect(user.first_name).to eq 'PreferredFirstname'
            expect(user.middle_name).to eq 'PreferredMiddlename'
            expect(user.last_name).to eq 'PreferredLastname'
            expect(user.psu_identity).to be_an_instance_of(PsuIdentity::SearchService::Person)
            expect(user.psu_identity_updated_at).to be_within(2.seconds).of(Time.zone.now)
          end
        end

        context 'when there are no users found' do
          it 'returns nil' do
            expect(user).to be_nil
          end
        end
      end

      context 'when PsuIdentity raises an error' do
        let(:mock_psu_identity_client) { instance_spy PsuIdentity::SearchService::Client }

        before do
          allow(PsuIdentity::SearchService::Client).to receive(:new).and_return(mock_psu_identity_client)
          allow(mock_psu_identity_client).to receive(:userid).and_raise(error_to_raise)
        end

        context 'when PsuIdentity raises URI::InvalidURIError' do
          let(:error_to_raise) { URI::InvalidURIError }

          it 'returns nil' do
            user = call
            expect(user).to be_nil
            expect(mock_psu_identity_client).to have_received(:userid).with(webaccess_id) # sanity
          end
        end

        context 'when PsuIdentity raises Timeout::Error' do
          let(:error_to_raise) { Timeout::Error }

          specify do
            expect { call }.to raise_error(described_class::IdentityServiceError)
          end
        end

        context 'when PsuIdentity raises StandardError' do
          let(:error_to_raise) { StandardError }

          specify do
            expect { call }.to raise_error(described_class::IdentityServiceError)
          end
        end
      end
    end
  end
end
