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
                         doi_verified: true,
                         oa_status_last_checked_at: Time.now - (1 * 60 * 30))}
    let!(:pub4) { create(:publication,
                         title: 'pub4',
                         doi_verified: nil,
                         oa_workflow_state: nil)}
    let!(:pub5) { create(:publication,
                         title: 'pub5',
                         doi_verified: nil,
                         oa_workflow_state: 'automatic DOI verification pending')}
    let!(:pub6) { create(:publication,
                         title: 'pub6',
                         doi_verified: true,
                         oa_workflow_state: nil)}
    let!(:open_access_location) { create(:open_access_location, publication: pub1) }
    let!(:activity_insight_oa_file1) { create(:activity_insight_oa_file, publication: pub2) }
    let!(:activity_insight_oa_file2) { create(:activity_insight_oa_file, publication: pub3) }
    let!(:activity_insight_oa_file3) { create(:activity_insight_oa_file, publication: pub4) }
    let!(:activity_insight_oa_file4) { create(:activity_insight_oa_file, publication: pub5) }
    let!(:activity_insight_oa_file5) { create(:activity_insight_oa_file, publication: pub6) }

    context 'when publications need doi verification' do
      before { allow(DoiVerificationJob).to receive(:perform_later) }

      it 'calls the doi verification job with that publication' do
        service.workflow
        expect(DoiVerificationJob).not_to have_received(:perform_later).with(pub1.id)
        expect(DoiVerificationJob).not_to have_received(:perform_later).with(pub2.id)
        expect(DoiVerificationJob).not_to have_received(:perform_later).with(pub3.id)
        expect(DoiVerificationJob).to have_received(:perform_later).with(pub4.id)
        expect(DoiVerificationJob).not_to have_received(:perform_later).with(pub5.id)
      end
    end

    context 'when there is an error' do
      before { allow(DoiVerificationJob).to receive(:perform_later).and_raise(RuntimeError) }

      it 'saves doi verifed as false' do
        service.workflow
      rescue RuntimeError
        expect(pub4.reload.doi_verified).to be false
      end
    end

    context 'when publications need oa metadata search' do
      before { allow(FetchOAMetadataJob).to receive(:perform_later) }

      it 'calls the fetch oa metadata job with that publication' do
        service.workflow
        expect(FetchOAMetadataJob).to have_received(:perform_later).with(pub6.id)
      end
    end
  end
end
