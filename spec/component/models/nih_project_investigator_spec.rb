# frozen_string_literal: true

require 'component/component_spec_helper'

describe NIHProjectInvestigator do
  let(:pi) { described_class.new(data) }
  let(:data) {
    {
      'first_name' => 'First',
      'middle_name' => middle_name,
      'last_name' => 'Last'
    }
  }
  let(:middle_name) { 'Middle' }

  describe '#first_name' do
    it 'returns the first name in lower case from the given metadata' do
      expect(pi.first_name).to eq 'first'
    end
  end

  describe '#middle_initial' do
    context 'when the given metadata has a middle name' do
      it 'returns the middle initial of the middle name in lower case from the given metadata' do
        expect(pi.middle_initial).to eq 'm'
      end
    end

    context 'when the given metadata has a blank middle name' do
      let(:middle_name) { '' }

      it 'returns nil' do
        expect(pi.middle_initial).to be_nil
      end
    end

    context 'when the given metadata has no middle name' do
      let(:middle_name) { nil }

      it 'returns nil' do
        expect(pi.middle_initial).to be_nil
      end
    end
  end

  describe '#last_name' do
    it 'returns the last name in lower case from the given metadata' do
      expect(pi.last_name).to eq 'last'
    end
  end
end
