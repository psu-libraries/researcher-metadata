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
                         oa_workflow_state: 'automatic DOI verification pending',
                         licence: 'licence')}
    let!(:pub7) { create(:publication,
                         title: 'pub7',
                         doi_verified: true,
                         permissions_last_checked_at: nil)}
    let!(:open_access_location) { create(:open_access_location, publication: pub1) }

    let!(:activity_insight_oa_file1) { create(:activity_insight_oa_file, publication: pub2, version: 'publishedVersion') }
    let!(:activity_insight_oa_file2) { create(:activity_insight_oa_file, publication: pub3, version: nil) }
    let!(:activity_insight_oa_file3) { create(:activity_insight_oa_file, publication: pub4, version: 'publishedVersion', version_checked: true) }
    let!(:activity_insight_oa_file4) { create(:activity_insight_oa_file, publication: pub5, version: 'acceptedVersion') }
    let!(:activity_insight_oa_file6) { create(:activity_insight_oa_file, publication: pub7, version: 'acceptedVersion', version_checked: nil) }

    context 'when publications need doi verification' do
      before do
        allow(DoiVerificationJob).to receive(:perform_later)
        allow(PermissionsCheckJob).to receive(:perform_later)
      end

      it 'calls the doi verification job with that publication' do
        service.workflow
        expect(DOIVerificationJob).not_to have_received(:perform_later).with(pub1.id)
        expect(DOIVerificationJob).not_to have_received(:perform_later).with(pub2.id)
        expect(DOIVerificationJob).not_to have_received(:perform_later).with(pub3.id)
        expect(DOIVerificationJob).to have_received(:perform_later).with(pub4.id)
        expect(DOIVerificationJob).not_to have_received(:perform_later).with(pub5.id)
      end

      context 'when there is an error' do
        before { allow(DoiVerificationJob).to receive(:perform_later).and_raise(RuntimeError) }

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
          expect(PermissionsCheckJob).not_to have_received(:perform_later).with(activity_insight_oa_file1.id)
          expect(PermissionsCheckJob).not_to have_received(:perform_later).with(activity_insight_oa_file2.id)
          expect(PermissionsCheckJob).not_to have_received(:perform_later).with(activity_insight_oa_file3.id)
          expect(PermissionsCheckJob).not_to have_received(:perform_later).with(activity_insight_oa_file4.id)
          expect(PermissionsCheckJob).to have_received(:perform_later).with(activity_insight_oa_file6.id)
        end
      end

      context 'when there is an error' do
        before { allow(PermissionsCheckJob).to receive(:perform_later).and_raise(RuntimeError) }

        it 'updates file version checked' do
          service.workflow
        rescue RuntimeError
          expect(activity_insight_oa_file6.reload.version_checked).to be true
        end
      end
    end
  end
end
