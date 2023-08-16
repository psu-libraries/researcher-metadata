# frozen_string_literal: true

require 'component/component_spec_helper'

describe PublicationDownloadJob, type: :job do
  let(:job) { described_class }

  describe '.perform_later' do
    ActiveJob::Base.queue_adapter = :test
    it 'enqueues a job' do
      expect { job.perform_later(1) }.to have_enqueued_job.with(1).on_queue('default')
    end
  end

  # This test is somewhat brittle and has a few dependencies that should be noted. It downloads
  # an actual file from the production instance of Activity Insight via the Activity Insight S3
  # Authorizer app's API. So this test will fail if the file is removed from Activity Insight or
  # if the Activity Insight S3 Authorizer is unreachable (i.e. if you're running this test from a
  # machine that is not on the Penn State network). The network firewall is also the reason why
  # this test can't currently be run on the CI server.
  describe '#perform_now', no_ci: true do
    let!(:publication) { create(:publication) }
    let!(:ai_oa_file) { create(:activity_insight_oa_file, publication: publication, version: 'acceptedVersion', location: 'nmg110/intellcont/test_file-1.pdf') }
    let(:file_path) { Rails.root.join("tmp/uploads/activity_insight_file_uploads/#{ai_oa_file.id}/file/test_file-1.pdf") }

    after do
      FileUtils.rm_f(file_path)
    end

    context 'when response code is "200"' do
      it 'saves the new file path' do
        job.perform_now(ai_oa_file.id)
        expect(ai_oa_file.reload.stored_file_path).to eq file_path.to_s
      end

      it 'uploads the file' do
        job.perform_now(ai_oa_file.id)
        expect(File.open(file_path).size).to eq 40451
      end
    end

    context 'when response code is not "200"' do
      let!(:ai_oa_file) { create(:activity_insight_oa_file, publication: publication, version: 'acceptedVersion', location: 'fakeperson/intellcont/test_file-1.pdf') }

      it 'does not store the file' do
        expect(Rails.logger).to receive(:error).with('500: Internal Server Error')
        job.perform_now(ai_oa_file.id)
        expect(ai_oa_file.reload.stored_file_path).to be_nil
        expect(File.exists?(file_path)).to be false
      end
    end
  end
end
