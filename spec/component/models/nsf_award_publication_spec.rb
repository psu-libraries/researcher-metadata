# frozen_string_literal: true

require 'component/component_spec_helper'

describe NSFAwardPublication do
  let(:pub) { described_class.new(data) }
  let(:data) {
    {
      'artTitl' => 'Test Title',
      'jrnlYr' => 2026,
      'dgtlObjId' => 'test-doi'
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

  describe '#title' do
    it 'returns the title from the given metadata' do
      expect(pub.title).to eq 'Test Title'
    end
  end

  describe '#year' do
    it 'returns the publication year from the given metadata' do
      expect(pub.year).to eq 2026
    end
  end

  describe '#doi' do
    it 'returns the DOI from the given metadata' do
      expect(pub.doi).to eq 'doi-url'
    end
  end
end
