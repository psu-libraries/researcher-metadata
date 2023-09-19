# frozen_string_literal: true

require 'component/component_spec_helper'

describe AiOAWfVersionCheckJob, type: :job do
  let(:job) { described_class }

  describe '.perform_later' do
    ActiveJob::Base.queue_adapter = :test
    it 'enqueues a job' do
      expect { job.perform_later(1) }.to have_enqueued_job.with(1).on_queue('default')
    end
  end

  describe '#perform_now' do
    let!(:ai_oa_file) { create(:activity_insight_oa_file) }

    context 'when exif version checker returns a version' do
      before do
        allow(ExifFileVersionChecker).to receive(:new).and_return double(version: 'acceptedVersion')
      end

      it "updates the file's version with the exif checker version and does not proceed with other check" do
        job.perform_now(ai_oa_file.id)
        expect(ai_oa_file.reload.version).to eq 'acceptedVersion'
      end
    end

    context 'when exif version checker does not return a version but pdf checker does' do
      before do
        allow(ExifFileVersionChecker).to receive(:new).and_return double(version: nil)
        allow(FileVersionChecker).to receive(:new).and_return double(version: 'publishedVersion')
      end

      it "updates the file's version with the pdf version checker version" do
        job.perform_now(ai_oa_file.id)
        expect(ai_oa_file.reload.version).to eq 'publishedVersion'
      end
    end

    context 'when an error occurs' do
      before do
        allow(ExifFileVersionChecker).to receive(:new).and_return double(version: nil)
        allow(FileVersionChecker).to receive(:new).and_raise RuntimeError
      end

      it "rescues the error and sets the file's version to unknown" do
        job.perform_now(ai_oa_file.id)
        expect(ai_oa_file.reload.version).to eq 'unknown'
      end
    end
  end
end
