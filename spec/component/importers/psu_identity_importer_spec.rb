# frozen_string_literal: true

require 'component/component_spec_helper'

describe PSUIdentityImporter do
  let(:importer) { described_class.new }
  let(:mock_client) { instance_spy(PsuIdentity::SearchService::Client) }
  let(:mock_person) { instance_spy(PsuIdentity::SearchService::Person) }

  let!(:user_1) { create(:user, webaccess_id: 'abc1') }
  let!(:user_2) { create(:user, webaccess_id: 'def2') }
  let!(:user_3) { create(:user, webaccess_id: 'ghi3') }

  before do
    allow(PsuIdentity::SearchService::Client).to receive(:new).and_return(mock_client)
    allow(mock_client).to receive(:userid).and_return(mock_person)
  end

  describe '#call' do
    context 'when there are no errors' do
      it 'no errors are logged and all users are updated' do
        importer.call

        expect(mock_client).to have_received(:userid).with(user_1.webaccess_id)
        expect(mock_client).to have_received(:userid).with(user_2.webaccess_id)
        expect(mock_client).to have_received(:userid).with(user_3.webaccess_id)
      end
    end

    context 'when PsuIdentity fails' do
      before do
        allow(mock_client).to receive(:userid).and_raise(RuntimeError)
        allow(ImporterErrorLog).to receive(:log_error)
      end

      it 'captures the error' do
        importer.call

        User.find_each do |user|
          expect(ImporterErrorLog).to have_received(:log_error).with(
            importer_class: described_class,
            error: PSUIdentityUserService::IdentityServiceError,
            metadata: {
              user_id: user.id
            }
          )
        end
      end
    end

    context 'when a user fails to update' do
      before do
        allow(mock_person).to receive(:preferred_given_name).and_raise(RuntimeError)
        allow(ImporterErrorLog).to receive(:log_error)
      end

      it 'captures the error' do
        importer.call

        expect(ImporterErrorLog).to have_received(:log_error).with(
          importer_class: described_class,
          error: instance_of(RuntimeError),
          metadata: {
            user_id: user_1.id
          }
        )
      end
    end

    context 'when the import fails' do
      before do
        allow(User).to receive(:find_each).and_raise(RuntimeError)
        allow(ImporterErrorLog).to receive(:log_error)
      end

      it 'logs the error' do
        importer.call

        expect(ImporterErrorLog).to have_received(:log_error).with(
          importer_class: described_class,
          error: instance_of(RuntimeError),
          metadata: {
            user_id: nil
          }
        )
      end
    end
  end
end
