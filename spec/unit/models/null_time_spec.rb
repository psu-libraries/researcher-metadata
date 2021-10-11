# frozen_string_literal: true

require 'unit/unit_spec_helper'
require_relative '../../../app/models/null_time'

describe NullTime do
  let(:nt) { described_class.new }

  describe '#<=>' do
    context 'when given a time' do
      it 'returns -1' do
        expect(nt.<=>(Time.new(2000, 1, 1, 0, 0, 0))).to eq -1
      end
    end

    context 'when given a null time' do
      it 'returns 0' do
        expect(nt.<=>(described_class.new)).to eq 0
      end
    end
  end

  describe '#<' do
    context 'when given a time' do
      it 'returns true' do
        expect(nt < Time.new(2000, 1, 1, 0, 0, 0)).to eq true
      end
    end

    context 'when given a null time' do
      it 'returns false' do
        expect(nt < described_class.new).to eq false
      end
    end
  end
end
