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
    let!(:publication) { create(:publication) }
    let!(:ai_oa_file) { create(:activity_insight_oa_file, publication: publication, version: 'acceptedVersion', location: 'location') }

    # this test depends on downloading an image file from the RMD homepage
    before do
      allow(File).to receive(:popen).with("wget -q --header 'X-API-Key: #{Settings.activity_insight_s3_authorizer.api_key}' -O - 'ai-s3-authorizer.k8s.libraries.psu.edu/api/v1/location'")
        .and_return(File.popen("wget -qO - 'https://metadata.libraries.psu.edu/assets/penn-state-libraries-logo-9b2587e3107e424a26741989c9784eca3c8ab9cc0849d740afcf1e7a84f9e3e0.png'"))
    end

    it 'saves the new file path' do
      job.perform_now(ai_oa_file.id)
      expect(ai_oa_file.reload.stored_file_path).to eq Rails.root.join("tmp/uploads/activity_insight_file_uploads/#{ai_oa_file.id}/file/location").to_s
    end

    it 'uploads the file' do
      job.perform_now(ai_oa_file.id)
      expect(File.open(Rails.root.join("tmp/uploads/activity_insight_file_uploads/#{ai_oa_file.id}/file/location")).size).to eq 13103
    end
  end
end
