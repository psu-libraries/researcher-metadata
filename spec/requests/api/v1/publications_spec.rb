require 'requests/requests_spec_helper'

describe 'API::V1 Publications' do
  describe 'GET /v1/publications' do
    context 'when no authorization header is included in the request' do
      it 'returns 401 Unauthorized' do
        get '/v1/publications'
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when an invalid authorization header value is included in the request' do
      it 'returns 401 Unauthorized' do
        get '/v1/publications', headers: { "X-API-Key": 'bad-token' }
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when a valid authorization header value is included in the request' do
      let!(:publications) { create_list(:publication, 10, visible: true) }
      let!(:invisible_pub) { create(:publication, visible: false) }
      let!(:inaccessible_pub) { create(:publication, visible: true) }
      let(:params) { '' }
      let!(:token) { create :api_token, token: 'token123', total_requests: 0, last_used_at: nil }
      let(:org) { create :organization }
      let(:user) { create :user }

      before do
        publications.each { |p| create :authorship, publication: p, user: user }
        create :user_organization_membership, user: user, organization: org
        create :organization_api_permission, organization: org, api_token: token
        get "/v1/publications#{params}", headers: { "X-API-Key": 'token123' }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status :ok
      end

      it 'returns all visible publications to which the given API token has access' do
        expect(json_response[:data].size).to eq(10)
      end

      it 'updates the usage statistics on the API token' do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end

      describe 'params:' do
        describe 'limit' do
          let(:params) { '?limit=5' }

          it 'returns the specified number of publications' do
            expect(json_response[:data].size).to eq(5)
          end
        end
      end
    end
  end

  describe 'GET /v1/publications/:id' do
    let!(:pub) { create :publication,
                        title: 'requested publication',
                        visible: visible }
    let!(:inaccessible_pub) { create :publication, visible: true }
    let!(:token) { create :api_token,
                          token: 'token123',
                          total_requests: 0,
                          last_used_at: nil }
    let(:visible) { true }
    let(:org) { create :organization }
    let(:user) { create :user }

    before do
      create :organization_api_permission, organization: org, api_token: token
      create :user_organization_membership, organization: org, user: user
      create :authorship, user: user, publication: pub
    end

    context 'when no authorization header is included in the request' do
      it 'returns 401 Unauthorized' do
        get "/v1/publications/#{pub.id}"
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when an invalid authorization header value is included in the request' do
      it 'returns 401 Unauthorized' do
        get "/v1/publications/#{pub.id}", headers: { "X-API-Key": 'bad-token' }
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when a valid authorization header value is included in the request' do
      context 'when requesting a visible publication' do
        before do
          get "/v1/publications/#{pub.id}", headers: { "X-API-Key": 'token123' }
        end

        it 'returns HTTP status 200' do
          expect(response).to have_http_status :ok
        end

        it 'returns the requested publication' do
          expect(
            json_response[:data][:attributes][:title]
          ).to eq 'requested publication'
        end

        it 'updates the usage statistics on the API token' do
          updated_token = token.reload
          expect(updated_token.total_requests).to eq 1
          expect(updated_token.last_used_at).not_to be_nil
        end
      end

      context 'when requesting an invisible publication' do
        let(:visible) { false }

        before do
          get "/v1/publications/#{pub.id}", headers: { "X-API-Key": 'token123' }
        end

        it 'returns HTTP status 404' do
          expect(response).to have_http_status :not_found
        end
      end

      context 'when requesting an inaccessible publication' do
        before do
          get "/v1/publications/#{inaccessible_pub.id}", headers: { "X-API-Key": 'token123' }
        end

        it 'returns HTTP status 404' do
          expect(response).to have_http_status :not_found
        end
      end
    end
  end

  describe 'GET /v1/publications/:id/grants' do
    let!(:pub) { create :publication, visible: visible }
    let!(:inaccessible_pub) { create :publication, visible: true }
    let!(:token) { create :api_token,
                          token: 'token123',
                          total_requests: 0,
                          last_used_at: nil }
    let(:visible) { true }
    let(:org) { create :organization }
    let(:user) { create :user }
    let(:g1) { create :grant }
    let(:g2) { create :grant }

    before do
      create :organization_api_permission, organization: org, api_token: token
      create :user_organization_membership, organization: org, user: user
      create :authorship, user: user, publication: pub
      create :research_fund, publication: pub, grant: g1
      create :research_fund, publication: pub, grant: g2
    end

    context 'when no authorization header is included in the request' do
      it 'returns 401 Unauthorized' do
        get "/v1/publications/#{pub.id}/grants"
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when an invalid authorization header value is included in the request' do
      it 'returns 401 Unauthorized' do
        get "/v1/publications/#{pub.id}/grants", headers: { "X-API-Key": 'bad-token' }
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when a valid authorization header value is included in the request' do
      context 'when requesting grants for a visible publication' do
        before do
          get "/v1/publications/#{pub.id}/grants", headers: { "X-API-Key": 'token123' }
        end

        it 'returns HTTP status 200' do
          expect(response).to have_http_status :ok
        end

        it 'returns the grants for the given publication' do
          expect(json_response[:data].size).to eq(2)
          expect(json_response[:data].detect { |grant| grant[:id] == g1.id.to_s && grant[:type] == 'grant' }).not_to be_nil
          expect(json_response[:data].detect { |grant| grant[:id] == g2.id.to_s && grant[:type] == 'grant' }).not_to be_nil
        end

        it 'updates the usage statistics on the API token' do
          updated_token = token.reload
          expect(updated_token.total_requests).to eq 1
          expect(updated_token.last_used_at).not_to be_nil
        end
      end

      context 'when requesting an invisible publication' do
        let(:visible) { false }

        before do
          get "/v1/publications/#{pub.id}/grants", headers: { "X-API-Key": 'token123' }
        end

        it 'returns HTTP status 404' do
          expect(response).to have_http_status :not_found
        end

        it 'updates the usage statistics on the API token' do
          updated_token = token.reload
          expect(updated_token.total_requests).to eq 1
          expect(updated_token.last_used_at).not_to be_nil
        end
      end

      context 'when requesting an inaccessible publication' do
        before do
          get "/v1/publications/#{inaccessible_pub.id}/grants", headers: { "X-API-Key": 'token123' }
        end

        it 'returns HTTP status 404' do
          expect(response).to have_http_status :not_found
        end

        it 'updates the usage statistics on the API token' do
          updated_token = token.reload
          expect(updated_token.total_requests).to eq 1
          expect(updated_token.last_used_at).not_to be_nil
        end
      end
    end
  end
end
