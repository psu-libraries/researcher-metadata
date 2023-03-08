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
