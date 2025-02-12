# frozen_string_literal: true

require 'component/component_spec_helper'

describe ActivityInsightPostprintStatusService do
  describe '#sync' do
    let!(:service) { described_class }
    let!(:pub1) { create(:publication, activity_insight_postprint_status: 'In Progress') }
    let!(:oal1) { create(:open_access_location, publication: pub1, url: 'https://scholarsphere.psu.edu') }
    let!(:aif1) { create(:activity_insight_oa_file, publication: pub1) }

    let!(:pub2) { create(:publication, activity_insight_postprint_status: 'In Progress', open_access_status: 'gold') }

    let!(:pub3) { create(:publication, activity_insight_postprint_status: 'In Progress') }

    let!(:pub4) { create(:publication, activity_insight_postprint_status: 'In Progress') }
    let!(:aif2) { create(:activity_insight_oa_file, publication: pub4, file_download_location: nil) }

    let!(:pub5) { create(:publication, activity_insight_postprint_status: nil) }
    let!(:aif3) { create(:activity_insight_oa_file, publication: pub5) }
    let!(:oal2) { create(:open_access_location, publication: pub5, source: Source::SCHOLARSPHERE) }

    let!(:pub6) { create(:publication, activity_insight_postprint_status: nil, open_access_status: 'gold') }
    let!(:aif4) { create(:activity_insight_oa_file, publication: pub6) }

    let!(:pub7) { create(:publication, activity_insight_postprint_status: nil, open_access_status: 'hybrid') }
    let!(:aif5) { create(:activity_insight_oa_file, publication: pub7) }

    let!(:pub8) { create(:publication, activity_insight_postprint_status: nil, open_access_status: nil, publication_type: 'Journal Article') }
    let!(:aif6) { create(:activity_insight_oa_file, publication: pub8, file_download_location: nil) }

    let!(:pub9) { create(:publication, activity_insight_postprint_status: nil, open_access_status: nil, publication_type: 'Other') }
    let!(:aif7) { create(:activity_insight_oa_file, publication: pub9) }

    before do
      allow(AiOAStatusExportJob).to receive(:perform_later)
      allow(PublicationDownloadJob).to receive(:perform_later)
    end

    it 'sets postprint status to already openly available for in progress publications and removes status for publications without sufficient file data' do
      service.sync

      expect(pub1.reload.activity_insight_postprint_status).to eq 'Already Openly Available'
      expect(pub2.reload.activity_insight_postprint_status).to eq 'Already Openly Available'
      expect(AiOAStatusExportJob).to have_received(:perform_later).with(aif1.id, 'Already Openly Available')
      expect(pub3.reload.activity_insight_postprint_status).to be_nil
      expect(pub4.reload.activity_insight_postprint_status).to be_nil
      expect(pub5.reload.activity_insight_postprint_status).to eq 'Already Openly Available'
      expect(AiOAStatusExportJob).to have_received(:perform_later).with(aif3.id, 'Already Openly Available')
      expect(pub6.reload.activity_insight_postprint_status).to eq 'Already Openly Available'
      expect(AiOAStatusExportJob).to have_received(:perform_later).with(aif4.id, 'Already Openly Available')
      expect(pub7.reload.activity_insight_postprint_status).to eq 'Already Openly Available'
      expect(AiOAStatusExportJob).to have_received(:perform_later).with(aif5.id, 'Already Openly Available')
      expect(pub8.reload.activity_insight_postprint_status).to eq 'In Progress'
      expect(AiOAStatusExportJob).to have_received(:perform_later).with(aif6.id, 'In Progress')
      expect(PublicationDownloadJob).to have_received(:perform_later).with(aif6.id)
      expect(pub9.reload.activity_insight_postprint_status).to be_nil
      expect(AiOAStatusExportJob).not_to have_received(:perform_later).with(aif7.id, 'Already Openly Available')
    end
  end
end
