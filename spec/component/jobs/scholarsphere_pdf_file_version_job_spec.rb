# frozen_string_literal: true

require 'component/component_spec_helper'

describe ScholarspherePdfFileVersionJob, type: :job do
  describe '.perform_later' do
    ActiveJob::Base.queue_adapter = :test
    let(:args) { { file_meta: [], publicaiton_meta: [], exif_file_version: nil } }

    it 'enqueues a job' do
      expect { described_class.perform_later(args) }.to have_enqueued_job.with(args).on_queue('scholarsphere-pdf-file-version')
    end
  end

  describe '#perform' do
    ActiveJob::Base.queue_adapter = :test
    let(:job) { described_class.new }
    let(:file_meta) { { original_filename: 'test_file', cache_path: 'path/to/test/file' } }
    let(:publication_meta) { { title: 'test_pub_title', year: '2000' } }
    let(:pdf_file_version) { double('ScholarspherePdfFileVersion', version: 'acceptedVersion') }
    let(:exif_file_version) { 'acceptedVersion' }

    before do
      allow(ScholarspherePdfFileVersion).to receive(:new)
        .with(file_meta: file_meta, publication_meta: publication_meta)
        .and_return(pdf_file_version)
    end

    it 'writes the correct file version to the cache' do
      expect(pdf_file_version).to receive(:version)
      expect(pdf_file_version.version).to eq 'acceptedVersion'
      expect(Rails.cache).to receive(:write).with("file_version_job_#{job.job_id}", { pdf_file_version: pdf_file_version.version, file_meta: file_meta, exif_file_version: exif_file_version })

      job.perform(file_meta: file_meta, publication_meta: publication_meta, exif_file_version: exif_file_version)
    end
  end
end
