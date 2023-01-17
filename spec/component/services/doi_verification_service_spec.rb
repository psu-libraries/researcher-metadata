# frozen_string_literal: true

require 'component/component_spec_helper'

describe DoiVerificationService do
  let(:publication) { double 'publication',
                              doi: 'https://doi.org/10.1016/S0962-1849(05)80014-9',
                              doi_url_path: '10.1016/S0962-1849(05)80014-9',
                              title: 'Psychotherapy integration and the need for better theories of change',
                              secondary_title: nil,
                              doi_verified: nil}
  let(:service) { described_class.new(publication) }

  describe '#verify' do
    context 'when a doi is valid' do
      #let(:get_unpaywall_data) {double('get_unpaywall_data')}
      #let(:compare_title) {double('compare_title')}

      it 'updates the publication doi_verified to true' do
        #allow(get_unpaywall_data).to receive().and_return 'Psychotherapy integration and the need for better theories of change: A rejoinder to Alford'
        #allow(compare_title).to receive(publication.title, 'Psychotherapy integration and the need for better theories of change: A rejoinder to Alford').and_return true
        service.verify
        expect(publication.doi_verified).to eq true
      end
    end

    context 'when a doi is not valid' do

      it 'updates the publication doi_verified to false' do

      end
    end
  end

  describe '#get_unpaywall_data' do
    it 'returns the publciation title' do

    end
  end

  describe '#compare_title' do
    context 'when titles are an exact match' do
      it 'returns true' do
        result = service.compare_title(publication.title, publication.title)
        expect(result).to eq true
      end
    end

    context 'when titles are a match but have different punctuation and casing' do
      let(:title2) { 'Psychotherapy Integration: and the Need for Better Theories of Change' }
      it 'returns true' do
        result = service.compare_title(publication.title, title2)
        expect(result).to eq true
      end
    end

    context 'when titles have at least 70% similarity' do
      let(:title2) { 'Psychotherapy integration: need for better theories of change' }
      it 'returns true' do
        result = service.compare_title(publication.title, title2)
        expect(result).to eq true
      end
    end

    context 'when titles have less than 70% similarity' do
      let(:title2) { 'Psychotherapy Integration: Theories of Change' }
      it 'returns false' do
        result = service.compare_title(publication.title, title2)
        expect(result).to eq false
      end
    end
  end
end
