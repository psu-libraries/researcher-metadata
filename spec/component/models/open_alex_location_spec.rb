# frozen_string_literal: true

require 'component/component_spec_helper'

describe OpenAlexLocation do
  let(:loc) { described_class.new(location_data, work) }
  let(:location_data) {
    {
      'id' => id,
      'landing_page_url' => 'test-landing-page-url',
      'pdf_url' => 'test-pdf-url',
      'source' => {
        'display_name' => 'Test Location',
        'type' => 'repository'
      },
      'license' => 'test license',
      'version' => 'test version',
      'is_published' => true
    }
  }
  let(:id) { 'abc123' }
  let(:work) {
    instance_double(
      OpenAlexWork,
      primary_location_id: 'abc123',
      best_oa_location_id: 'abc123'
    )
  }

  describe '#id' do
    it 'returns the ID for the location from the given metadata' do
      expect(loc.id).to eq 'abc123'
    end
  end

  describe '#name' do
    it 'retuns the display_name of the location source from the given metadata' do
      expect(loc.name).to eq 'Test Location'
    end
  end

  describe '#host_type' do
    it 'returns the type of the location source from the given metadata' do
      expect(loc.host_type).to eq 'repository'
    end
  end

  describe '#primary?' do
    context "when the given metadata is for a location with the same ID as the work's primary location" do
      it 'returns true' do
        expect(loc.primary?).to be true
      end
    end

    context "when the given metadata is for a location with a different ID than the work's primary location" do
      let(:id) { 'def456' }

      it 'returns false' do
        expect(loc.primary?).to be false
      end
    end
  end

  describe '#best_oa?' do
    context "when the given metadata is for a location with the same ID as the work's best open access location" do
      it 'returns true' do
        expect(loc.best_oa?).to be true
      end
    end

    context "when the given metadata is for a location with a different ID than the work's best open access location" do
      let(:id) { 'def456' }

      it 'returns false' do
        expect(loc.best_oa?).to be false
      end
    end
  end

  describe '#license' do
    it 'retuns the license for the location from the given metadata' do
      expect(loc.license).to eq 'test license'
    end
  end

  describe '#landing_page_url' do
    it 'retuns the landing page URL for the location from the given metadata' do
      expect(loc.landing_page_url).to eq 'test-landing-page-url'
    end
  end

  describe '#pdf_url' do
    it 'retuns the PDF URL for the location from the given metadata' do
      expect(loc.pdf_url).to eq 'test-pdf-url'
    end
  end

  describe '#version' do
    it 'retuns the version for the location from the given metadata' do
      expect(loc.version).to eq 'test version'
    end
  end

  describe '#published?' do
    it 'returns the is_published value for the location from the given metadata' do
      expect(loc.published?).to be true
    end
  end
end
