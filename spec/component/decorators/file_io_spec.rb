# frozen_string_literal: true

require 'component/component_spec_helper'

describe FileIO do
  let(:file) { instance_double File, size: 123 }
  let(:fio) { FileIO.new(file, 'test.pdf') }

  describe '#size' do
    it "delegates to the object with which it was initialized" do
      expect(fio.size).to eq 123
    end
  end
  describe '#path' do
    it "returns the filename with which it was initialized" do
      expect(fio.path).to eq 'test.pdf'
    end
  end

  describe '#to_path' do
    it "returns the filename with which the object was initialized" do
      expect(fio.to_path).to eq 'test.pdf'
    end
  end

  describe '#rewind' do
    it "returns 0" do
      expect(fio.rewind).to eq 0
    end
  end
end
