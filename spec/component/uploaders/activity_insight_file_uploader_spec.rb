# frozen_string_literal: true

require 'component/component_spec_helper'

describe ActivityInsightFileUploader do
  describe '.storage' do
    it 'uses the local filesystem' do
      expect(described_class.storage).to eq CarrierWave::Storage::File
    end
  end
end
