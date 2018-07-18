require 'requests/requests_spec_helper'

describe 'API::V1 Users' do
  describe 'GET /v1/users/:webaccess_id/publications' do
    let!(:user) { create(:user_with_authorships, webaccess_id: 'xyz321', authorships_count: 10) }
    let(:webaccess_id) { user.webaccess_id }
    let(:params) { '' }

    before do
      get "/v1/users/#{webaccess_id}/publications#{params}", headers: { 'Accept': 'application/vnd' }
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
end
