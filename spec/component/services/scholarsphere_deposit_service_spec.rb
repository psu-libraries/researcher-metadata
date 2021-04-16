require 'component/component_spec_helper'

describe ScholarsphereDepositService do
  let(:service) { ScholarsphereDepositService.new(deposit, user) }
  let(:user) { double 'user', webaccess_id: 'abc123' }
  let(:deposit) { double 'scholarsphere work deposit',
                         metadata: metadata,
                         files: files }
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
    context "when the ScholarSphere client returns a 200 response" do
      it "records the successful response with the URI that is returned" do
        expect(deposit).to receive(:record_success).with("https://scholarsphere-qa.dsrd.libraries.psu.edu/the-url")
        service.create
      end
    end

    context "when the ScholarSphere client returns a response that is not 200" do
      let(:status) { 500 }

      it "records the failed response with the error message that is returned" do
        expect(deposit).to receive(:record_failure).with(response_body)
        service.create
      end
    end
  end
end
