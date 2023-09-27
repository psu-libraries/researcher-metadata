# frozen_string_literal: true

require 'component/component_spec_helper'

describe OAWorkflowService do
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
                         permissions_last_checked_at: DateTime.now,
                         oa_status_last_checked_at: Time.now - (1 * 60 * 30))}
    let!(:pub4) { create(:publication,
                         title: 'pub4',
                         doi_verified: nil,
                         oa_workflow_state: nil,
                         permissions_last_checked_at: DateTime.now)}
    let!(:pub5) { create(:publication,
                         title: 'pub5',
                         doi_verified: nil,
                         oa_workflow_state: 'automatic DOI verification pending',
                         licence: 'licence')}
    let!(:pub6) { create(:publication,
                         title: 'pub6',
                         doi_verified: true,
                         oa_workflow_state: nil,
                         open_access_status: 'green')}
    let!(:pub7) { create(:publication,
                         title: 'pub7',
                         licence: 'licence',
                         open_access_status: 'gold')}
    let!(:open_access_location) { create(:open_access_location, publication: pub1) }

    let!(:activity_insight_oa_file1) { create(:activity_insight_oa_file, publication: pub2) }
    let!(:activity_insight_oa_file2) { create(:activity_insight_oa_file, publication: pub3) }
    let!(:activity_insight_oa_file3) { create(:activity_insight_oa_file, publication: pub4) }
    let!(:activity_insight_oa_file4) { create(:activity_insight_oa_file, publication: pub5, exported_oa_status_to_activity_insight: true) }
    let!(:activity_insight_oa_file5) { create(:activity_insight_oa_file, publication: pub6) }
    let!(:activity_insight_oa_file6) { create(:activity_insight_oa_file, publication: pub7, downloaded: true) }

    context 'when publications need doi verification' do
      before do
        allow(PermissionsCheckJob).to receive(:perform_later)
        allow(DOIVerificationJob).to receive(:perform_later)
      end

      it 'calls the doi verification job with that publication' do
        service.workflow
        expect(DOIVerificationJob).not_to have_received(:perform_later).with(pub1.id)
        expect(DOIVerificationJob).not_to have_received(:perform_later).with(pub2.id)
        expect(DOIVerificationJob).not_to have_received(:perform_later).with(pub3.id)
        expect(DOIVerificationJob).to have_received(:perform_later).with(pub4.id)
        expect(DOIVerificationJob).not_to have_received(:perform_later).with(pub5.id)
        expect(DOIVerificationJob).not_to have_received(:perform_later).with(pub6.id)
      end

      context 'when there is an error' do
        before { allow(DOIVerificationJob).to receive(:perform_later).with(pub4.id).and_raise(RuntimeError) }

        it 'saves doi verifed as false' do
          service.workflow
        rescue RuntimeError
          expect(pub4.reload.doi_verified).to be false
        end
      end
    end

    context 'when publications need permissions checks' do
      context 'when there is not an error' do
        before { allow(PermissionsCheckJob).to receive(:perform_later) }

        it 'calls the permissions check job with that publication' do
          service.workflow
          expect(PermissionsCheckJob).not_to have_received(:perform_later).with(pub1.id)
          expect(PermissionsCheckJob).not_to have_received(:perform_later).with(pub2.id)
          expect(PermissionsCheckJob).not_to have_received(:perform_later).with(pub3.id)
          expect(PermissionsCheckJob).not_to have_received(:perform_later).with(pub4.id)
          expect(PermissionsCheckJob).not_to have_received(:perform_later).with(pub5.id)
          expect(PermissionsCheckJob).to have_received(:perform_later).with(pub6.id)
        end
      end

      context 'when there is an error' do
        before { allow(PermissionsCheckJob).to receive(:perform_later).and_raise(RuntimeError) }

        it 'updates permissions_last_checked_at checked' do
          service.workflow
        rescue RuntimeError
          expect(pub6.reload.permissions_last_checked_at).to be_present
        end
      end
    end

    context 'when publications need oa metadata search' do
      before { allow(FetchOAMetadataJob).to receive(:perform_later) }

      it 'calls the fetch oa metadata job with that publication' do
        service.workflow
        expect(FetchOAMetadataJob).to have_received(:perform_later).with(pub6.id)
        expect(FetchOAMetadataJob).not_to have_received(:perform_later).with(pub3.id)
      end
    end

    context 'when Activity Insight files are ready for download' do
      before { allow(PublicationDownloadJob).to receive(:perform_later) }

      it 'calls the publication download job with that file' do
        service.workflow
        expect(PublicationDownloadJob).to have_received(:perform_later).with(activity_insight_oa_file4.id)
        expect(PublicationDownloadJob).to have_received(:perform_later).with(activity_insight_oa_file5.id)
        expect(PublicationDownloadJob).not_to have_received(:perform_later).with(activity_insight_oa_file6.id)
        expect(activity_insight_oa_file4.reload.downloaded).to be true
      end

      context 'when there is an error' do
        before { allow(PublicationDownloadJob).to receive(:perform_later).and_raise(RuntimeError) }

        it 'updates file downloaded status' do
          service.workflow
        rescue RuntimeError
          expect(activity_insight_oa_file4.reload.downloaded).to be false
        end
      end
    end

    context 'when Activity Insight files are ready for oa status export' do
      before { allow(AiOAStatusExportJob).to receive(:perform_later) }

      it 'calls the AiOAStatusExportJob' do
        service.workflow
        expect(AiOAStatusExportJob).to have_received(:perform_later).with(activity_insight_oa_file6.id)
        expect(AiOAStatusExportJob).not_to have_received(:perform_later).with(activity_insight_oa_file4.id)
        expect(activity_insight_oa_file6.reload.exported_oa_status_to_activity_insight).to be true
      end
    end
  end
end
