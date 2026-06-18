# frozen_string_literal: true

require 'component/component_spec_helper'

describe OpenAlexAPIClient do
  let(:client) { described_class.new }
  let(:open_alex_settings) { double('options', api_key: 'secret-api-key') }

  before do
    allow(Settings).to receive(:open_alex).and_return open_alex_settings
  end

  describe '#get_works' do
    let(:response) { instance_double(HTTParty::Response, body: response_body) }
    let(:response_body) { %{{"test": "response"}} }

    before do
      allow(HTTParty).to receive(:get).with(
        'https://api.openalex.org/works?filter=institutions.id:I130769515,type:dataset&per_page=100&cursor=cur123&api_key=secret-api-key'
      ).and_return response
    end

    it 'returns parsed JSON from the Open Alex works API for the given parameters' do
      expect(client.get_works(type: 'dataset', cursor: 'cur123')).to eq({ 'test' => 'response' })
    end
  end
end
