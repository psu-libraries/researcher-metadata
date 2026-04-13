# frozen_string_literal: true

require 'component/component_spec_helper'

describe NSFAwards do
  let(:awards) { described_class.new(data) }
  let(:data) { double 'awards data' }
  let(:a1) { double 'award 1' }
  let(:a2) { double 'award 2' }
  let(:nsf_a1) { instance_double NSFAward }
  let(:nsf_a2) { instance_double NSFAward }
  let(:parsed_json) {
    {
      'response' => {
        'award' => [a1, a2]
      }
    }
  }

  before do
    allow(JSON).to receive(:parse).with(data).and_return parsed_json
    allow(NSFAward).to receive(:new).with(a1).and_return nsf_a1
    allow(NSFAward).to receive(:new).with(a2).and_return nsf_a2
  end

  describe '#each' do
    it 'yields an NSFAward to the given block for each award in the given data' do
      expect { |b| awards.each(&b) }.to yield_successive_args(nsf_a1, nsf_a2)
    end
  end

  describe '#count' do
    it 'returns the number of awards in the given data' do
      expect(awards.count).to eq 2
    end
  end
end
