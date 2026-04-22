# frozen_string_literal: true

require 'component/component_spec_helper'

describe NIHProjectPublication do
  let(:pub) { described_class.new(data) }
  let(:data) { double 'publication data' }
  let(:parsed_data) { instance_double Nokogiri::XML::Document }
  let(:doi_element) { instance_double Nokogiri::XML::Element, content: 'test-doi' }
  let(:title_element) { instance_double Nokogiri::XML::Element, content: 'Test Title' }
  let(:pub_date_element) { instance_double Nokogiri::XML::Element, content: '2021 Oct' }
  let(:doi_sanitizer) {
    instance_double(
      DOISanitizer,
      url: 'doi-url'
    )
  }

  before do
    allow(Nokogiri).to receive(:parse).with(data).and_return parsed_data
    allow(DOISanitizer).to receive(:new).with('test-doi').and_return doi_sanitizer
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
    it 'returns the publication year from the given metadata' do
      expect(pub.year).to eq 2021
    end
  end

  describe '#doi' do
    it 'returns the DOI from the given metadata' do
      expect(pub.doi).to eq 'doi-url'
    end
  end
end
