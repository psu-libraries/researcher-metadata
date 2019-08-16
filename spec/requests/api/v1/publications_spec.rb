require 'requests/requests_spec_helper'

describe 'API::V1 Publications' do
  describe 'GET /v1/publications' do
    context "when no authorization header is included in the request" do
      it "returns 401 Unauthorized" do
        get "/v1/publications"
        expect(response).to have_http_status 401
      end
    end
    context "when an invalid authorization header value is included in the request" do
      it "returns 401 Unauthorized" do
        get "/v1/publications", headers: {"X-API-Key": 'bad-token'}
        expect(response).to have_http_status 401
      end
    end
    context "when a valid authorization header value is included in the request" do
      let!(:publications) { create_list(:publication, 10, visible: true) }
      let!(:invisible_pub) { create(:publication, visible: false) }
      let(:params) { '' }
      let!(:token) { create :api_token, token: 'token123', total_requests: 0, last_used_at: nil }

      before do
        get "/v1/publications#{params}", headers: {"X-API-Key": 'token123'}
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      it 'returns all visible publications' do
        expect(json_response[:data].size).to eq(10)
      end
      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end

      describe 'params:' do
        describe 'limit' do
          let(:params) { "?limit=5"}
          it 'returns the specified number of publications' do
            expect(json_response[:data].size).to eq(5)
          end
        end
      end
    end
  end

  describe 'GET /v1/publications/:id' do

    let!(:requested_publication) {
      create(:publication, title: 'requested publication', visible: visible)
    }
    let(:visible) { nil }

    context "when no authorization header is included in the request" do
      it "returns 401 Unauthorized" do
        get "/v1/publications/#{requested_publication.id}"
        expect(response).to have_http_status 401
      end
    end
    context "when an invalid authorization header value is included in the request" do
      it "returns 401 Unauthorized" do
        get "/v1/publications/#{requested_publication.id}", headers: {"X-API-Key": 'bad-token'}
        expect(response).to have_http_status 401
      end
    end
    context "when a valid authorization header value is included in the request" do
      let!(:token) { create :api_token, token: 'token123', total_requests: 0, last_used_at: nil }

      context "when requesting a visible publication" do
        let(:visible) { true }

        before do
          get "/v1/publications/#{requested_publication.id}", headers: {"X-API-Key": 'token123'}
        end

        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end
        it 'returns the requested publication' do
          expect(
            json_response[:data][:attributes][:title]
          ).to eq 'requested publication'
        end
        it "updates the usage statistics on the API token" do
          updated_token = token.reload
          expect(updated_token.total_requests).to eq 1
          expect(updated_token.last_used_at).not_to be_nil
        end
      end

      context "when requesting an invisible publication" do
        let(:visible) { false }

        before do
          get "/v1/publications/#{requested_publication.id}", headers: {"X-API-Key": 'token123'}
        end

        it 'returns HTTP status 404' do
          expect(response).to have_http_status 404
        end
      end
    end
  end
end
