# frozen_string_literal: true

require 'component/component_spec_helper'

describe ActivityInsightOAWorkflow::MetadataCurationController, type: :controller do
  describe '#create_scholarsphere_deposit' do
    let!(:user) { create(:user, is_admin: true) }
    let!(:publication) { create(:sample_publication, :oa_publication, preferred_version: 'acceptedVersion') }
    let!(:ai_oa_file) { create(:activity_insight_oa_file, publication: publication, version: 'acceptedVersion') }

    context 'when publications cannot be deposited to scholarsphere' do
      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
        allow(publication).to receive(:scholarsphere_upload_pending?).and_return(true)
      end

      it 'redirects to metadata review list' do
        post :create_scholarsphere_deposit, params: { publication_id: publication.id }
        expect(flash[:warning]).to eq 'This publication cannot be deposited.'
        expect(response.redirect_url).to include activity_insight_oa_workflow_metadata_review_path
      end
    end
  end
end
