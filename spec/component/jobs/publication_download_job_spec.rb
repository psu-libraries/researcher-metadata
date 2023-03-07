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
    let!(:ai_oa_file) { create(:activity_insight_oa_file, publication: publication, version: 'acceptedVersion', location: 'location.jpg') }

    # this test depends on downloading an image file from the RMD homepage
    before do
      allow_any_instance_of(ActivityInsightOAFile).to receive(:download_uri).and_return(URI('http://townsquare.media/site/705/files/2022/05/attachment-Puppies-and-Pancakes.jpg?w=980&q=75')) # rubocop:todo RSpec/AnyInstance
    end

    it 'saves the new file path' do
      job.perform_now(ai_oa_file.id)
      expect(ai_oa_file.reload.stored_file_path).to eq Rails.root.join("tmp/uploads/activity_insight_file_uploads/#{ai_oa_file.id}/file/location.jpg").to_s
    end

    it 'uploads the file' do
      job.perform_now(ai_oa_file.id)
      expect(File.open(Rails.root.join("tmp/uploads/activity_insight_file_uploads/#{ai_oa_file.id}/file/location.jpg")).size).to eq 85577
    end
  end
end
