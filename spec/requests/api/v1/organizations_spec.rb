require 'requests/requests_spec_helper'

describe 'API::V1 Organizations' do
  describe 'GET /v1/organizations' do
    context "when no authorization header is included in the request" do
      it "returns 401 Unauthorized" do
        get "/v1/organizations"
        expect(response).to have_http_status 401
      end
    end
    context "when an invalid authorization header value is included in the request" do
      it "returns 401 Unauthorized" do
        get "/v1/organizations", headers: {"X-API-Key": 'bad-token'}
        expect(response).to have_http_status 401
      end
    end
    context "when a valid authorization header value is included in the request" do
      let!(:org1) { create :organization, visible: true }
      let!(:org2) { create :organization, visible: true }
      let!(:invisible_org) { create(:organization, visible: false) }
      let!(:token) { create :api_token, token: 'token123', total_requests: 0, last_used_at: nil }

      before do
        get "/v1/organizations", headers: {"X-API-Key": 'token123'}
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      it 'returns all visible organizations' do
        expect(json_response[:data].size).to eq(2)
      end
      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end
    end
  end
end
