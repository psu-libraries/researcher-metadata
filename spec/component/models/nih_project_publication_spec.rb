# frozen_string_literal: true

require 'component/component_spec_helper'

describe NIHProjectPublication do
  let(:pub) { described_class.new(data) }
  let(:data) { double 'publication data' }
  let(:parsed_data) { instance_double Nokogiri::XML::Document }
  let(:doi_element) { instance_double Nokogiri::XML::Element, content: 'test-doi' }
  let(:title_element) { instance_double Nokogiri::XML::Element, content: 'Test Title' }
  let(:pub_date_element) { instance_double Nokogiri::XML::Element, content: '2021 Oct' }
  let(:doi_sanitizer_non_nil) {
    instance_double(
      DOISanitizer,
      url: 'doi-url'
    )
  }
  let(:doi_sanitizer_nil) {
    instance_double(
      DOISanitizer,
      url: nil
    )
  }

  before do
    allow(Nokogiri).to receive(:parse).with(data).and_return parsed_data
    allow(DOISanitizer).to receive(:new).with('test-doi').and_return doi_sanitizer_non_nil
    allow(DOISanitizer).to receive(:new).with(nil).and_return doi_sanitizer_nil
    allow(parsed_data).to receive(:at_xpath).with("//eSummaryResult//DocSum//Item[@Name='DOI']").and_return doi_element
    allow(parsed_data).to receive(:at_xpath).with("//eSummaryResult//DocSum//Item[@Name='Title']").and_return title_element
    allow(parsed_data).to receive(:at_xpath).with("//eSummaryResult//DocSum//Item[@Name='PubDate']").and_return pub_date_element
  end

  describe '#title' do
    it 'returns the title from the given metadata' do
      expect(pub.title).to eq 'Test Title'
    end
  end

  describe '#year' do
    context 'when the given metadata contains a publication year' do
      it 'returns the publication year from the given metadata' do
        expect(pub.year).to eq 2021
      end
    end

    context 'when the given metadata does not contain a publication year' do
      let(:pub_date_element) { nil }

      it 'raises an error' do
        expect { pub.year }.to raise_error NIHProjectPublication::MissingMetadata
      end
    end
  end

  describe '#doi' do
    context 'when the given metadata contains a DOI' do
      it 'returns the DOI from the given metadata' do
        expect(pub.doi).to eq 'doi-url'
      end
    end

    context 'when the given metadata does not contain a DOI' do
      let(:doi_element) { nil }

      it 'returns nil' do
        expect(pub.doi).to be_nil
      end
    end
  end
end
