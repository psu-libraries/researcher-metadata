# frozen_string_literal: true

require 'component/component_spec_helper'

describe OpenAlexWork do
  let(:work) { described_class.new(work_data) }
  let(:work_data) {
    {
      'doi' => 'test-doi'
    }
  }
  let(:doi_sanitizer) {
    instance_double(
      DOISanitizer,
      url: 'doi-url'
    )
  }

  before do
    allow(DOISanitizer).to receive(:new).with('test-doi').and_return doi_sanitizer
  end

  describe '#doi' do
    it 'returns the DOI from the given metadata' do
      expect(work.doi).to eq 'doi-url'
    end
  end
end
