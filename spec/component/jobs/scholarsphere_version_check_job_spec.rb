# frozen_string_literal: true

require 'component/component_spec_helper'

describe ScholarsphereVersionCheckJob, type: :job do
  describe '.perform_later' do
    ActiveJob::Base.queue_adapter = :test
    let(:args) { { file_path: [], publication: [] } }

    it 'enqueues a job' do
      expect { described_class.perform_later(args) }.to have_enqueued_job.with(args).on_queue('scholarsphere-pdf-file-version')
    end
  end

  describe '#perform' do
    ActiveJob::Base.queue_adapter = :test
    let(:job) { described_class.new }
    let(:file_path) { 'path/to/test/file' }
    let(:publication) { create(:publication, { title: 'test_pub_title', published_on: '2000' }) }
    let(:pdf_file_version) { double('FileVersionChecker', version: 'acceptedVersion', score: 2) }

    before do
      allow(FileVersionChecker).to receive(:new)
        .with(file_path: file_path, publication: publication)
        .and_return(pdf_file_version)
    end

    it 'writes the correct file version to the cache' do
      expect(pdf_file_version).to receive(:version)
      expect(pdf_file_version.version).to eq 'acceptedVersion'
      expect(Rails.cache).to receive(:write).with("file_version_job_#{job.job_id}", { pdf_file_version: pdf_file_version.version, pdf_file_score: 2, file_path: file_path })

      job.perform(file_path: file_path, publication_id: publication.id)
    end
  end
end
