# frozen_string_literal: true

require 'component/component_spec_helper'

describe OABResponse do
  let(:response) { described_class.new(json) }
  let(:json) { JSON.parse(Rails.root.join('spec', 'fixtures', 'oab3.json').read) }

  describe '#url' do
    it 'returns url' do
      expect(response.url).to eq 'http://arxiv.org/pdf/gr-qc/9801069'
    end
  end

  describe '#doi' do
    context 'when the response has a DOI' do
      it 'returns doi' do
        expect(response.doi).to eq 'https://doi.org/10.1103/PhysRevLett.80.3915'
      end
    end

    context 'when the response does not have a DOI' do
      let(:json) { JSON.parse(Rails.root.join('spec', 'fixtures', 'oab5.json').read) }

      it 'returns nil' do
        expect(response.doi).to be_nil
      end
    end
  end
end
