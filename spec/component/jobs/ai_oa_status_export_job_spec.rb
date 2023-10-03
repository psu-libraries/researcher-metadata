# frozen_string_literal: true

require 'component/component_spec_helper'

describe AiOAStatusExportJob, type: :job do
  let(:job) { described_class }

  describe '.perform_later' do
    ActiveJob::Base.queue_adapter = :test
    it 'enqueues a job' do
      expect { job.perform_later(1) }.to have_enqueued_job.with(1).on_queue('default')
    end
  end

  describe '#perform_now' do
    let!(:aif1) { create(:activity_insight_oa_file, publication: pub1, version: 'publishedVersion', file_download_location: fixture_file_open('test_file.pdf')) }
    let!(:pub1) { create(:publication, preferred_version: 'None', title: 'Title 1') }
    let(:exporter) { instance_double ActivityInsightOAStatusExporter }
    let(:base_dir) { aif1.file_download_location.model_object_dir }

    before do
      allow(ActivityInsightOAStatusExporter).to receive(:new).with(aif1.id, export_status).and_return(exporter)
    end

    after do
      FileUtils.rm_f(base_dir)
    end

    context 'when the export status is Already Openly Available' do
      let(:export_status) { 'Already Openly Available' }


      it 'calls the ActivityInsightOAStatusExporter without error' do
        expect(exporter).to receive(:export)
        job.perform_now(aif1.id, export_status)
        expect(File.exists?(aif1.file_download_location.model_object_dir)).to eq true
        expect(aif1.stored_file_path).not_to be_nil
      end

      it 'does not raise an error' do
        expect { job.perform_now(aif1.id, export_status) }.not_to raise_error AiOAStatusExportJob::InvalidExportStatus
      end
    end

    context 'when the export status is Cannot Deposit' do
      let(:export_status) { 'Cannot Deposit' }

      it 'calls the ActivityInsightOAStatusExporter without error and removes the file download directory' do
        expect(exporter).to receive(:export)
        job.perform_now(aif1.id, export_status)
        expect(File.exists?(aif1.file_download_location.model_object_dir)).to eq false
        expect(aif1.reload.stored_file_path).to be_nil
      end

      it 'does not raise an error' do
        expect { job.perform_now(aif1.id, export_status) }.not_to raise_error AiOAStatusExportJob::InvalidExportStatus
      end
    end

    context 'when the export status is invalid' do
      let(:export_status) { 'Not valid' }

      it 'raises an error' do
        expect { job.perform_now(aif1.id, export_status) }.to raise_error AiOAStatusExportJob::InvalidExportStatus, 'Not valid'
      end
    end
  end
end
