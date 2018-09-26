require 'requests/requests_spec_helper'

describe 'API::V1 Users' do

  describe 'GET /v1/users/:webaccess_id/contracts' do
    let!(:user) { create(:user_with_contracts, webaccess_id: 'xyz321', contracts_count: 10) }
    let(:webaccess_id) { user.webaccess_id }
    let(:params) { '' }
    let(:headers) { { "accept" => "application/json" } }

    before do
      get "/v1/users/#{webaccess_id}/contracts#{params}", headers: headers
    end

    context "for a valid webaccess_id" do
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      context "when the user has contracts" do
        it "returns all the user's contracts" do
          expect(json_response[:data].size).to eq(10)
        end
      end
      context "when the user has no contracts" do
        let(:user_without_contracts) { create(:user, webaccess_id: "nocons123") }
        let(:webaccess_id) { user_without_contracts.webaccess_id }
        it "returns an empty JSON data hash" do
          expect(json_response[:data].size).to eq(0)
        end
      end
      context "when an html-formatted response is requested" do
        let(:headers) { { "accept" => "text/html" } }
        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end
      end
    end
  end

  describe 'GET /v1/users/:webaccess_id/publications' do
    let!(:user) { create(:user_with_authorships, webaccess_id: 'xyz321', authorships_count: 10) }
    let!(:invisible_pub) { create :publication, visible: false }
    let(:webaccess_id) { user.webaccess_id }
    let(:params) { '' }
    let(:headers) { { "accept" => "application/json" } }

    before do
      create :authorship, user: user, publication: invisible_pub
      get "/v1/users/#{webaccess_id}/publications#{params}", headers: headers
    end

    context "for a valid webaccess_id" do
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      context "when the user has publications" do
        it "returns all the user's visible publications" do
          expect(json_response[:data].size).to eq(10)
        end
        describe 'params:' do
          describe 'limit' do
            let(:params) { "?limit=5"}
            it "returns the specified number of publications" do
              expect(json_response[:data].size).to eq(5)
            end
          end
        end
      end
      context "when the user has no publications" do
        let(:user_without_publications) { create(:user, webaccess_id: "nopubs123") }
        let(:webaccess_id) { user_without_publications.webaccess_id }
        it "returns an empty JSON data hash" do
          expect(json_response[:data].size).to eq(0)
        end
      end
      context "when an html-formatted response is requested" do
        let(:headers) { { "accept" => "text/html" } }
        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end
      end
    end
    context "for an invalid webaccess_id" do
      let(:webaccess_id) { "aaa" }
      it "returns 404 not found" do
        expect(response).to have_http_status 404
      end
    end
  end

  describe 'POST /v1/users/publications' do
    let!(:user_xyz123) { create(:user_with_authorships, webaccess_id: 'xyz321', authorships_count: 10) }
    let!(:user_abc123) { create(:user_with_authorships, webaccess_id: 'abc123', authorships_count: 5) }

    let!(:user_cws161) { create(:user, webaccess_id: 'cws161') }

    let!(:invisible_pub1) { create :publication, visible: false }
    let!(:invisible_pub2) { create :publication, visible: false }

    before do
      create :authorship, user: user_abc123, publication: invisible_pub1
      create :authorship, user: user_cws161, publication: invisible_pub2

      post "/v1/users/publications", params: params
    end
    context "for a valid set of webaccess_id params" do
      let(:params) { { '_json': %w(abc123 xyz321 cws161 fake123) } }
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      it "returns visible publications for each webaccess_id" do
        expect(json_response.count).to eq(3)
        expect(json_response[:abc123][:data].count).to eq(5)
        expect(json_response[:xyz321][:data].count).to eq(10)
        expect(json_response[:cws161][:data].count).to eq(0)
      end
    end
  end

  describe 'GET /v1/users/:webaccess_id/etds' do
    let!(:user) { create(:user_with_committee_memberships, webaccess_id: 'xyz321', committee_memberships_count: 10) }
    let(:webaccess_id) { user.webaccess_id }
    let(:params) { '' }
    let(:headers) { { "accept" => "application/json" } }

    before do
      get "/v1/users/#{webaccess_id}/etds#{params}", headers: headers
    end

    context "for a valid webaccess_id" do
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      context "when the user served on etd committees" do
        it "returns all the etds the user was a committee member on" do
          expect(json_response[:data].size).to eq(10)
        end
      end
      context "when the user has not served on any committees" do
        let(:user_without_etds) { create(:user, webaccess_id: "nocommittees123") }
        let(:webaccess_id) { user_without_etds.webaccess_id }
        it "returns an empty JSON data hash" do
          expect(json_response[:data].size).to eq(0)
        end
      end
      context "when an html-formatted response is requested" do
        let(:headers) { { "accept" => "text/html" } }
        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end
      end
    end
    context "for an invalid webaccess_id" do
      let(:webaccess_id) { "aaa" }
      it "returns 404 not found" do
        expect(response).to have_http_status 404
      end
    end
  end
end
