# frozen_string_literal: true

require 'component/component_spec_helper'

describe FetchOAMetadataJob, type: :job do
  let(:job) { described_class }

  describe '.perform_later' do
    ActiveJob::Base.queue_adapter = :test
    it 'enqueues a job' do
      expect { job.perform_later(1) }.to have_enqueued_job.with(1).on_queue('default')
    end
  end

  describe '#perform_now' do
    let!(:pub) { create(:publication,
                        doi: 'https://doi.org/10.1103/physrevlett.80.3915',
                        open_access_locations: [],
                        unpaywall_last_checked_at: nil,
                        open_access_button_last_checked_at: nil,
                        open_access_status: nil) }
    let(:unpaywall_json) { Rails.root.join('spec', 'fixtures', 'unpaywall1.json').read }
    let(:oab_json) { Rails.root.join('spec', 'fixtures', 'oab3.json').read }

    before do
      allow(HttpService).to receive(:get).with('https://api.unpaywall.org/v2/10.1103/physrevlett.80.3915?email=openaccess@psu.edu').and_return(unpaywall_json)
      allow(HttpService).to receive(:get).with('https://api.openaccessbutton.org/find?id=10.1103%2Fphysrevlett.80.3915').and_return(oab_json)
    end

    context 'when unpaywall has open access information' do
      before { job.perform_now(pub.id) }

      it 'updates publication with unpaywall open access information' do
        expect(pub.reload.open_access_locations).not_to eq []
        expect(pub.reload.open_access_status).to eq 'green'
      end

      it "updates publication's unpaywall last checked at" do
        expect(pub.reload.unpaywall_last_checked_at).to be_within(1.minute).of(Time.zone.now)
      end
    end

    context 'when unpaywall does not have open access information' do
      let(:unpaywall_json) { Rails.root.join('spec', 'fixtures', 'unpaywall2.json').read }

      context 'when OAB has open access information' do
        before { job.perform_now(pub.id) }

        it 'updates publication with OAB open access information' do
          expect(pub.reload.open_access_locations).not_to eq []
        end

        it "updates publication's open access button last checked at" do
          expect(pub.reload.open_access_button_last_checked_at).to be_within(1.minute).of(Time.zone.now)
        end

        it 'updates the publication oa status last checked at, oa status, and workflow state' do
          expect(pub.reload.open_access_status).to eq 'closed'
          expect(pub.reload.oa_status_last_checked_at).to be_within(1.minute).of(Time.zone.now)
          expect(pub.reload.oa_workflow_state).to be_nil
        end
      end

      context 'when there is no open access information' do
        before { job.perform_now(pub.id) }

        let(:oab_json) { Rails.root.join('spec', 'fixtures', 'oab5.json').read }

        it 'does not update the publication oa data' do
          expect(pub.reload.open_access_locations).to eq []
          expect(pub.reload.unpaywall_last_checked_at).to be_nil
          expect(pub.reload.open_access_button_last_checked_at).to be_nil
        end

        it 'updates the publication oa status last checked at, oa status, and workflow state' do
          expect(pub.reload.open_access_status).to eq 'closed'
          expect(pub.reload.oa_status_last_checked_at).to be_within(1.minute).of(Time.zone.now)
          expect(pub.reload.oa_workflow_state).to be_nil
        end
      end
    end
  end
end
