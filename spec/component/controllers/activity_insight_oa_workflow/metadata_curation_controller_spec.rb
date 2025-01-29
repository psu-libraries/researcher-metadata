# frozen_string_literal: true

require 'component/component_spec_helper'

describe ActivityInsightOAWorkflow::MetadataCurationController, type: :controller do
  describe '#create_scholarsphere_deposit' do
    let!(:user) { create(:user, is_admin: true) }
    let!(:author) { create(:user, :with_psu_identity) }
    let!(:publication) { create(:sample_publication, :oa_publication, preferred_version: 'acceptedVersion') }
    let!(:auth) { create(:authorship, publication: publication, user: author) }
    let!(:ai_oa_file) {
      create(
        :activity_insight_oa_file,
        publication: publication,
        version: 'acceptedVersion',
        license: 'https://creativecommons.org/licenses/by/4.0/',
        set_statement: 'statement',
        embargo_date: Date.today,
        downloaded: true,
        file_download_location: fixture_file_open('test_file.pdf'),
        user: author
      )
    }

    before do
      allow(request.env['warden']).to receive(:authenticate!).and_return(user)
      allow(controller).to receive(:current_user).and_return(user)
    end

    context 'when publication cannot be deposited to scholarsphere' do
      before do
        publication.update abstract: nil
      end

      it 'redirects to metadata review list' do
        post :create_scholarsphere_deposit, params: { publication_id: publication.id }
        expect(flash[:alert]).to eq 'This publication cannot be deposited.'
        expect(response.redirect_url).to include activity_insight_oa_workflow_metadata_review_path
      end
    end

    context 'when publication is not ready for metadata review' do
      before do
        publication.update preferred_version: nil
      end

      it 'redirects to metadata review list' do
        post :create_scholarsphere_deposit, params: { publication_id: publication.id }
        expect(flash[:notice]).to eq 'This publication is not ready for metadata review.'
        expect(response.redirect_url).to include activity_insight_oa_workflow_metadata_review_path
      end
    end
  end
end
