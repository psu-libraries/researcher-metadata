# frozen_string_literal: true

require 'requests/requests_spec_helper'

describe API::V1::OrganizationsController do
  describe 'GET /v1/organizations' do
    context 'when no authorization header is included in the request' do
      it 'returns 401 Unauthorized' do
        get '/v1/organizations'
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when an invalid authorization header value is included in the request' do
      it 'returns 401 Unauthorized' do
        get '/v1/organizations', headers: { 'X-API-Key': 'bad-token' }
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when a valid authorization header value is included in the request' do
      let!(:org1) { create(:organization, visible: true) }
      let!(:org2) { create(:organization, visible: true) }
      let!(:org3) { create(:organization, visible: true) }
      let!(:invisible_org) { create(:organization, visible: false) }
      let!(:token) { create(:api_token, token: 'token123', total_requests: 0, last_used_at: nil) }

      before do
        create(:organization_api_permission, api_token: token, organization: org1)
        create(:organization_api_permission, api_token: token, organization: org2)
        get '/v1/organizations', headers: { 'X-API-Key': 'token123' }
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status :ok
      end

      it 'returns all visible organizations that the API token has permission to view' do
        expect(json_response[:data].size).to eq(2)

        expect(json_response[:data].find { |o| o[:id] == org1.id.to_s }).not_to be_nil
        expect(json_response[:data].find { |o| o[:id] == org2.id.to_s }).not_to be_nil
      end

      it 'updates the usage statistics on the API token' do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end
    end
  end

  describe 'GET /v1/organizations/:id/publications' do
    let!(:user_1) { create(:user) }
    let!(:user_2) { create(:user) }
    let!(:user_3) { create(:user) }
    let!(:pub_1) { create(:publication, published_on: Date.new(2000, 1, 1), visible: true) }
    let!(:pub_2) { create(:publication, published_on: Date.new(2010, 1, 1), visible: true) }
    let!(:pub_3) { create(:publication, published_on: Date.new(2015, 1, 1), visible: true) }
    let!(:invisible_pub) { create(:publication, published_on: Date.new(2010, 1, 1), visible: false) }
    let!(:org) { create(:organization, visible: true) }
    let!(:child_org) { create(:organization, visible: true, parent: org) }
    let!(:inaccessible_org) { create(:organization, visible: true) }
    let!(:invisible_org) { create(:organization, visible: false) }
    let(:headers) { { 'accept' => 'application/json', 'X-API-Key' => 'token123' } }
    let!(:token) { create(:api_token, token: 'token123', total_requests: 0, last_used_at: nil) }

    before do
      create(:user_organization_membership,
             user: user_1,
             organization: org,
             started_on: Date.new(1990, 1, 1))
      create(:user_organization_membership,
             user: user_2,
             organization: org,
             started_on: Date.new(1980, 1, 1))
      create(:user_organization_membership,
             user: user_3,
             organization: child_org,
             started_on: Date.new(2000, 1, 1))

      create(:authorship, user: user_1, publication: pub_1)
      create(:authorship, user: user_2, publication: pub_2)
      create(:authorship, user: user_2, publication: invisible_pub)
      create(:authorship, user: user_3, publication: pub_3)

      create(:organization_api_permission, api_token: token, organization: org)
    end

    context 'when no authorization header is included in the request' do
      it 'returns 401 Unauthorized' do
        get '/v1/organizations'
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when an invalid authorization header value is included in the request' do
      it 'returns 401 Unauthorized' do
        get '/v1/organizations', headers: { 'X-API-Key': 'bad-token' }
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when a valid authorization header value is included in the request' do
      context 'when given the ID of a visible organization' do
        let(:query_params) { nil }

        before do
          get "/v1/organizations/#{org.id}/publications#{query_params}", headers: headers
        end

        it 'updates the usage statistics on the API token' do
          updated_token = token.reload
          expect(updated_token.total_requests).to eq 1
          expect(updated_token.last_used_at).not_to be_nil
        end

        context 'when no query parameters are passed' do
          it "returns all the organization's visible publications" do
            expect(json_response[:data].size).to eq(3)
            expect(json_response[:data].pluck(:attributes).pluck(:title)).to eq([pub_1.title, pub_2.title, pub_3.title])
          end
        end

        context 'when the offset query parameter is passed' do
          let(:query_params) { '?offset=1' }

          it "returns all the organization's visible publications after the offset number" do
            expect(json_response[:data].size).to eq(2)
            expect(json_response[:data].pluck(:attributes).pluck(:title)).to eq([pub_2.title, pub_3.title])
          end
        end

        context 'when the limit query parameter is passed' do
          let(:query_params) { '?limit=1' }

          it "returns a limited number of the organization's visible publications" do
            expect(json_response[:data].size).to eq(1)
            expect(json_response[:data].pluck(:attributes).pluck(:title)).to eq([pub_1.title])
          end
        end

        context 'when the limit and offset query parameters are passed' do
          let(:query_params) { '?offset=1&limit=1' }

          it "returns a limited number of the organization's visible publications after the offset number" do
            expect(json_response[:data].size).to eq(1)
            expect(json_response[:data].pluck(:attributes).pluck(:title)).to eq([pub_2.title])
          end
        end
      end

      context 'when given the ID of an invisible organization' do
        before do
          get "/v1/organizations/#{invisible_org.id}/publications", headers: headers
        end

        it 'updates the usage statistics on the API token' do
          updated_token = token.reload
          expect(updated_token.total_requests).to eq 1
          expect(updated_token.last_used_at).not_to be_nil
        end

        it 'returns 404' do
          expect(response).to have_http_status :not_found
        end
      end

      context 'when given the ID of an organization to which the token does not have access' do
        before do
          get "/v1/organizations/#{inaccessible_org.id}/publications", headers: headers
        end

        it 'updates the usage statistics on the API token' do
          updated_token = token.reload
          expect(updated_token.total_requests).to eq 1
          expect(updated_token.last_used_at).not_to be_nil
        end

        it 'returns 404' do
          expect(response).to have_http_status :not_found
        end
      end
    end
  end
end
