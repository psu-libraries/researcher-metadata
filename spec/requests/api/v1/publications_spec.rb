require 'requests/requests_spec_helper'

describe 'Publications API::V1' do
  describe 'GET /v1/publications' do
    let!(:publications) { create_list(:publication, 10) }

    before do
      get '/v1/publications', headers: { 'Accept': 'application/vnd' }
    end

    it 'returns HTTP status 200' do
      expect(response).to have_http_status 200
    end
    it 'returns all publications' do
      expect(json_response[:data].size).to eq(10)
    end
  end

  describe 'GET /v1/publications/:id' do
    let!(:publications) { create_list(:publication, 10) }
    let!(:requested_publication) {
      create(:publication, title: 'requested publication')
    }

    before do
      get "/v1/publications/#{requested_publication.id}", headers: { 'Accept': 'application/vnd' }
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
end
