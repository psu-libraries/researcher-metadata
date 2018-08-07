require 'requests/requests_spec_helper'

describe 'API::V1 Users' do
  describe 'GET /v1/users/:webaccess_id/publications' do
    let!(:user) { create(:user_with_authorships, webaccess_id: 'xyz321', authorships_count: 10) }
    let(:webaccess_id) { user.webaccess_id }
    let(:params) { '' }

    before do
      get "/v1/users/#{webaccess_id}/publications#{params}"
    end

    context "for a valid webaccess_id" do
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      context "when the user has publications" do
        it "returns all the user's publications" do
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
    before do
      post "/v1/users/publications", params: params
    end
    context "for a valid set of webaccess_id params" do
      let(:params) { { '_json': %w(abc123 xyz321 cws161 fake123) } }
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      it "returns publications for each webaccess_id" do
        expect(json_response.count).to eq(3)
        expect(json_response[:abc123][:data].count).to eq(5)
        expect(json_response[:xyz321][:data].count).to eq(10)
        expect(json_response[:cws161][:data].count).to eq(0)
      end
    end
  end
end
