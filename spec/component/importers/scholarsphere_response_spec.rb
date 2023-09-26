# frozen_string_literal: true

require 'component/component_spec_helper'

describe ScholarsphereResponse do
  let(:response) { described_class.new(http_response) }
  let(:http_response) { double 'HTTParty', parsed_response: parsed_response }
  let(:parsed_response) { [{ 'url' => '/resources/651e7b9a-a4f8-482e-9855-91944bf40d00' }] }

  describe '#doi_found?' do
    context 'when there is a url value' do
      it 'returns true' do
        expect(response.doi_found?).to be true
      end
    end

    context 'when there is not a url value' do
      let(:parsed_response) { nil }

      it 'returns false' do
        expect(response.doi_found?).to be false
      end
    end
  end

  describe '#url' do
    context 'when a url is present in the response' do
      it 'returns the url' do
        expect(response.url).to eq '/resources/651e7b9a-a4f8-482e-9855-91944bf40d00'
      end
    end

    context 'when a url is not present in the response' do
      let(:parsed_response) { nil }

      it 'returns nil' do
        expect(response.url).to be_nil
      end
    end
  end
end
