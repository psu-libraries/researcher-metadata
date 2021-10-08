# frozen_string_literal: true

require 'component/component_spec_helper'

describe ScholarsphereDepositService do
  let(:service) { described_class.new(deposit, user) }
  let(:user) { double 'user', webaccess_id: 'abc123' }
  let(:deposit) { double 'scholarsphere work deposit',
                         metadata: metadata,
                         files: files,
                         record_success: nil }
  let(:metadata) { double 'metadata' }
  let(:files) { double 'files' }
  let(:ingest) { double 'scholarsphere client ingest', publish: response }
  let(:response) { double 'scholarsphere client response', status: status, body: response_body }
  let(:response_body) { %{{"url": "/the-url"}} }
  let(:status) { 200 }

  before do
    allow(Scholarsphere::Client::Ingest).to receive(:new).with(
      {
        metadata: metadata,
        files: files,
        depositor: 'abc123'
      }
    ).and_return ingest
  end

  describe '#create' do
    let(:email) { double 'email', deliver_now: nil }
    let(:profile) { double 'user profile' }

    before do
      allow(ResearcherMetadata::Application).to receive(:scholarsphere_base_uri).and_return 'https://scholarsphere.test'
      allow(FacultyConfirmationsMailer).to receive(:scholarsphere_deposit_confirmation).with(profile, deposit).and_return email
      allow(UserProfile).to receive(:new).with(user).and_return(profile)
    end

    context 'when the ScholarSphere client returns a 200 response' do
      it 'records the successful response with the URI that is returned' do
        expect(deposit).to receive(:record_success).with('https://scholarsphere.test/the-url')
        service.create
      end

      it 'sends a confirmation email to the user' do
        expect(email).to receive(:deliver_now)
        service.create
      end
    end

    context 'when the ScholarSphere client returns a response that is not 200' do
      let(:status) { 500 }

      it 'raises an error' do
        expect { service.create }.to raise_error ScholarsphereDepositService::DepositFailed, response_body
      end
    end
  end
end
