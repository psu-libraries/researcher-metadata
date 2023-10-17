# frozen_string_literal: true

require 'component/component_spec_helper'

describe ScholarsphereDepositService do
  let(:service) { described_class.new(deposit, user) }
  let(:user) { double 'user', webaccess_id: 'abc123' }
  let(:deposit) { double 'scholarsphere work deposit',
                         metadata: metadata,
                         files: files,
                         record_success: nil,
                         standard_oa_workflow?: true,
                         activity_insight_oa_file_id: 1 }
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
    let(:standard_email) { double 'standard_email', deliver_now: nil }
    let(:ai_oa_email) { double 'ai_oa_email', deliver_now: nil }
    let(:profile) { double 'user profile' }

    before do
      allow(ResearcherMetadata::Application).to receive(:scholarsphere_base_uri).and_return 'https://scholarsphere.test'
      allow(FacultyConfirmationsMailer).to receive(:scholarsphere_deposit_confirmation).with(profile, deposit).and_return standard_email
      allow(FacultyConfirmationsMailer).to receive(:ai_oa_workflow_scholarsphere_deposit_confirmation).with(profile, deposit).and_return ai_oa_email
      allow(UserProfile).to receive(:new).with(user).and_return(profile)
    end

    context 'when the ScholarSphere client returns a 200 response' do
      it 'records the successful response with the URI that is returned' do
        expect(deposit).to receive(:record_success).with('https://scholarsphere.test/the-url')
        service.create
      end

      context "when deposit's #standard_oa_workflow? is true" do
        it 'sends a confirmation email to the user' do
          expect(standard_email).to receive(:deliver_now)
          expect(ai_oa_email).not_to receive(:deliver_now)
          service.create
        end
      end

      context "when deposit's #standard_oa_workflow? is false" do
        before { allow(deposit).to receive(:standard_oa_workflow?).and_return false }

        it 'sends a confirmation email to the user and enqueues a job to export post print status to Activity Insight' do
          expect(ai_oa_email).to receive(:deliver_now)
          expect(standard_email).not_to receive(:deliver_now)
          expect(AiOAStatusExportJob).to receive(:perform_later).with(1, 'Deposited to ScholarSphere')
          service.create
        end
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
