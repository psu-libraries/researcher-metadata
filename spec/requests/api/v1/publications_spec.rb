require 'requests/requests_spec_helper'

describe 'API::V1 Publications' do
  describe 'GET /v1/publications' do
    let!(:publications) { create_list(:publication, 10, visible: true) }
    let!(:invisible_pub) { create(:publication, visible: false) }
    let(:params) { '' }

    before do
      get "/v1/publications#{params}"
    end

    it 'returns HTTP status 200' do
      expect(response).to have_http_status 200
    end
    it 'returns all visible publications' do
      expect(json_response[:data].size).to eq(10)
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

  describe 'GET /v1/publications/:id' do
    let!(:publications) { create_list(:publication, 10, visible: true) }
    let!(:requested_publication) {
      create(:publication, title: 'requested publication', visible: visible)
    }
    context "when requesting a visible publication" do
      let(:visible) { true }

      before do
        get "/v1/publications/#{requested_publication.id}"
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      it 'returns the requested publication' do
        expect(
          json_response[:data][:attributes][:title]
        ).to eq 'requested publication'
      end
    end

    context "when requesting an invisible publication" do
      let(:visible) { false }

      before do
        get "/v1/publications/#{requested_publication.id}"
      end

      it 'returns HTTP status 404' do
        expect(response).to have_http_status 404
      end
    end
  end
end
