# frozen_string_literal: true

require 'component/component_spec_helper'

describe AiPublicationExportJob, type: :job do
  let(:job) { described_class }

  describe '.perform_later' do
    ActiveJob::Base.queue_adapter = :test
    it 'enqueues a job' do
      expect { job.perform_later(1) }.to have_enqueued_job.with(1).on_queue('ai-publication-export')
    end
  end

  describe '#perform_now' do
    let!(:publication1) { create(:sample_publication) }
    let!(:publication2) { create(:sample_publication) }

    it 'instantiates ActivityInsightPublicationExporter with publications and target and triggers the export method' do
      obj = double('ActivityInsightPublicationExporter', export: nil)
      allow(ActivityInsightPublicationExporter).to receive(:new).with([publication1, publication2], 'beta').and_return(obj)
      job.perform_now([publication1.id, publication2.id], 'beta')
      expect(ActivityInsightPublicationExporter).to have_received(:new).with([publication1, publication2], 'beta')
      expect(obj).to have_received(:export)
    end
  end
end
