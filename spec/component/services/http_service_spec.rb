# frozen_string_literal: true

require 'component/component_spec_helper'

describe HttpService do
  describe '#get' do
    context 'when the HTTP request is successful' do
      before do
        allow(HTTParty).to receive(:get).and_return 'some data'
      end

      it 'returns the correct data' do
        response = described_class.get('http://test.com')

        expect(response).to eq 'some data'
      end
    end

    context 'when the HTTP request times out too many times' do
      before do
        allow(HTTParty).to receive(:get).and_raise(Net::ReadTimeout)
      end

      it 'raises an error' do
        expect { described_class.get('url') }.to raise_error(Net::ReadTimeout)
      end
    end
  end
end
