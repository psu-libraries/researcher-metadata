# frozen_string_literal: true

require 'component/component_spec_helper'

describe ScholarsphereUploadJob, type: :job do
  describe '.perform_later' do
    ActiveJob::Base.queue_adapter = :test
    it 'enqueues a job' do
      expect { described_class.perform_later(1, 2) }.to have_enqueued_job.with(1, 2).on_queue("scholarsphere-uploads-#{`hostname`}".strip)
    end
  end

  describe '#perform' do
    ActiveJob::Base.queue_adapter = :test
    let(:job) { described_class.new }
    let(:user) { create(:user) }
    let(:deposit) { create(:scholarsphere_work_deposit) }
    let(:service) { double 'scholarsphere deposit service' }
    let(:profile) { double 'user profile' }

    before { allow(ScholarsphereDepositService).to receive(:new).with(deposit, user).and_return(service) }

    it 'sends a message to the service' do
      expect(service).to receive(:create)
      job.perform(deposit.id, user.id)
    end

    context 'when an error is raised in performing the job' do
      let(:failure_email) { double 'email', deliver_now: nil }

      before do
        allow(UserProfile).to receive(:new).with(user).and_return(profile)
        allow(FacultyNotificationsMailer).to receive(:scholarsphere_deposit_failure).with(profile, deposit).and_return failure_email
        allow(service).to receive(:create).and_raise RuntimeError.new('some unexpected error')
      end

      it 'records the error on the deposit' do
        suppress(RuntimeError) { job.perform(deposit.id, user.id) }

        dep = deposit.reload
        expect(dep.status).to eq 'Failed'
        expect(dep.error_message).to eq 'some unexpected error'
      end

      it 'sends a notification email to the user' do
        expect(failure_email).to receive(:deliver_now)
        suppress(RuntimeError) { job.perform(deposit.id, user.id) }
      end
    end
  end
end
