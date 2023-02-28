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

  describe '#perform_now' do
    let!(:publication) { create(:publication)}
    let!(:ai_oa_file) { create(:activity_insight_oa_file, publication: publication, version: 'acceptedVersion') }
    let(:returned_file) { fixture_file_upload('test_file.pdf', 'application/pdf') }

    before do
      allow(HTTParty).to receive(:get).with().and_return(returned_file) #add AI request
    end

    it 'saves the new file path' do
      job.perform_now(ai_oa_file.id)
      expect(ai_oa_file.stored_file_path).to eq "tmp/uploads/cache/activity_insight_file_uploads/#{model&.id || object_id}/file"
    end
  end
end