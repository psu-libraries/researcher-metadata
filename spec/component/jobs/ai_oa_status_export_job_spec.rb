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
    let!(:aif1) { create(:activity_insight_oa_file, publication: pub1, exported_oa_status_to_activity_insight: nil) }
    let(:pub1) { create(:publication, open_access_status: 'gold') }
    let(:exporter) { instance_double ActivityInsightOAStatusExporter }

    before { allow(ActivityInsightOAStatusExporter).to receive(:new).with(aif1.id, 'Already Openly Available').and_return(exporter) }

    it 'calls the ActivityInsightOAStatusExporter' do
      expect(exporter).to receive(:export)
      job.perform_now(aif1.id, 'Already Openly Available')
    end
  end
end
