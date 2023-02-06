# frozen_string_literal: true

require 'component/component_spec_helper'

describe OaWorkflowService do
  describe '#workflow' do
    let(:service) { described_class.new }
    let!(:pub1) { create(:publication,
                         title: 'pub1',
                         doi_verified: nil)}
    let!(:pub2) { create(:publication,
                         title: 'pub2',
                         doi_verified: false)}
    let!(:pub3) { create(:publication,
                         title: 'pub3',
                         doi_verified: true)}
    let!(:pub4) { create(:publication,
                         title: 'pub4',
                         doi_verified: nil,
                         oa_workflow_state: nil)}
    let!(:pub5) { create(:publication,
                         title: 'pub5',
                         doi_verified: nil,
                         oa_workflow_state: 'automatic DOI verification pending')}
    let!(:open_access_location) { create(:open_access_location, publication: pub1) }
    let!(:activity_insight_oa_file1) { create(:activity_insight_oa_file, publication: pub2) }
    let!(:activity_insight_oa_file2) { create(:activity_insight_oa_file, publication: pub3) }
    let!(:activity_insight_oa_file3) { create(:activity_insight_oa_file, publication: pub4) }
    let!(:activity_insight_oa_file4) { create(:activity_insight_oa_file, publication: pub5) }
    let(:doi_job) { instance_spy DoiVerificationJob }

    context 'when publications need doi verification' do
      before { allow(DoiVerificationJob).to receive(:new).and_return(doi_job) }

      it 'calls the doi verification job with that publication' do
        service.workflow
        expect(doi_job).not_to have_received(:perform).with(pub1)
        expect(doi_job).not_to have_received(:perform).with(pub2)
        expect(doi_job).not_to have_received(:perform).with(pub3)
        expect(doi_job).to have_received(:perform).with(pub4)
        expect(doi_job).not_to have_received(:perform).with(pub5)
      end
    end

    context 'when there is an error' do
      before { allow(DoiVerificationJob).to receive(:new).and_raise(RuntimeError) }

      it 'saves doi verifed as false' do
        service.workflow
        expect(pub4.reload.doi_verified).to be false
      end
    end
  end
end
