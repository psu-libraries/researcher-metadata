# frozen_string_literal: true

require 'component/component_spec_helper'

describe NIHProjectInvestigator do
  let(:pi) { described_class.new(data) }
  let(:data) {
    {
      'first_name' => 'First',
      'middle_name' => 'Middle',
      'last_name' => 'Last'
    }
  }

  describe '#first_name' do
    it 'returns the first name from the given metadata' do
      expect(pi.first_name).to eq 'First'
    end
  end

  describe '#middle_name' do
    it 'returns the middle name from the given metadata' do
      expect(pi.middle_name).to eq 'Middle'
    end
  end

  describe '#last_name' do
    it 'returns the last name from the given metadata' do
      expect(pi.last_name).to eq 'Last'
    end
  end
end
