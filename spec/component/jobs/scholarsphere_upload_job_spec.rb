require 'component/component_spec_helper'

describe ScholarsphereUploadJob, type: :job do
  describe '.perform_later' do
    ActiveJob::Base.queue_adapter = :test
    it "enqueues a job" do
      expect { ScholarsphereUploadJob.perform_later(1, 2) }.to have_enqueued_job
    end
  end

  describe '#perform' do
    ActiveJob::Base.queue_adapter = :test
    let(:job) { ScholarsphereUploadJob.new }
    let(:user) { create :user }
    let(:deposit) { create :scholarsphere_work_deposit }
    let(:service) { double 'scholarsphere deposit service' }

    before { allow(ScholarsphereDepositService).to receive(:new).with(deposit, user).and_return(service) }

    it "sends a message to the service" do
      expect(service).to receive(:create)
      job.perform(deposit.id, user.id)
    end
  end
end
