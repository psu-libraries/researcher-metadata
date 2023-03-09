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

    it 'saves the new file path' do
      job.perform_now(ai_oa_file.id)
      expect(ai_oa_file.reload.stored_file_path).to eq Rails.root.join("tmp/uploads/activity_insight_file_uploads/#{ai_oa_file.id}/file/test_file-1.pdf").to_s
    end

    it 'uploads the file' do
      job.perform_now(ai_oa_file.id)
      expect(File.open(Rails.root.join("tmp/uploads/activity_insight_file_uploads/#{ai_oa_file.id}/file/test_file-1.pdf")).size).to eq 40451
    end
  end
end
