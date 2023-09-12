# frozen_string_literal: true

require 'requests/requests_spec_helper'
require 'support/authentication'

describe ActivityInsightOAWorkflow::WrongFileVersionCurationController do
  describe 'POST /activity_insight_oa_workflow/wrong_file_version_curation/email_author' do
    let(:user) { create(:user, is_admin: true) }

    before do
      sign_in_as(user)
      post user_azure_oauth_omniauth_authorize_path
    end

    context 'when given a publication id that has a correct file version' do
      let!(:aif1) { create(:activity_insight_oa_file, publication: pub1, version: 'acceptedVersion') }
      let!(:pub1) { create(:publication, preferred_version: 'acceptedVersion') }

      xit 'does not send an email and raises an error' do
        post activity_insight_oa_workflow_wrong_file_version_email_path, params: { publications: [pub1] }

        expect(response).to have_http_status :not_found
      end
    end
  end
end
