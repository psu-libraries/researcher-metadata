# frozen_string_literal: true

require 'component/component_spec_helper'

describe OpenAlexDatasetImporter do
  describe '.call' do
    it 'exists' do
      expect { described_class.call }.not_to raise_error
    end
  end
end
