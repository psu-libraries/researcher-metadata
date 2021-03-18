require 'component/component_spec_helper'

describe ScholarsphereFileUploader do
  describe '.storage' do
    it "uses the local filesystem" do
      expect(ScholarsphereFileUploader.storage).to eq CarrierWave::Storage::File
    end
  end
end
