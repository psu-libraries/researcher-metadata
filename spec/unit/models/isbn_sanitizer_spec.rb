# frozen_string_literal: true

require 'unit/unit_spec_helper'
require_relative '../../../app/models/issn_sanitizer'
require_relative '../../../app/models/isbn_sanitizer'
require_relative '../../../app/models/doi_sanitizer'

describe ISBNSanitizer do
  let(:isbn_value) { nil }
  let(:isbn) { described_class.new(isbn_value) }

  describe '#isbn' do
    context 'given a nil value' do
      it 'returns nil' do
        expect(isbn.isbn).to be_nil
      end
    end

    context 'given an empty string value' do
      let(:isbn_value) { '' }

      it 'returns nil' do
        expect(isbn.isbn).to be_nil
      end
    end

    context 'given a blank string value' do
      let(:isbn_value) { ' ' }

      it 'returns nil' do
        expect(isbn.isbn).to be_nil
      end
    end

    context 'given a valid ISBN' do
      let(:isbn_value) { '978-0-596-52068-7' }

      it 'returns the ISBN' do
        expect(isbn.isbn).to eq '978-0-596-52068-7'
      end
    end

    context 'given a valid ISBN with ISBN prefix' do
      let(:isbn_value) { 'ISBN 978-0-596-52068-7' }

      it 'returns the ISBN' do
        expect(isbn.isbn).to eq 'ISBN 978-0-596-52068-7'
      end
    end

    context 'given an ISBN value that is missing digits' do
      let(:isbn_value) { '90-596-5206' }

      it 'returns nil' do
        expect(isbn.isbn).to be_nil
      end
    end

    context 'given an ISBN value with letters' do
      let(:isbn_value) { '0-ABC-52068-7' }

      it 'returns nil' do
        expect(isbn.isbn).to be_nil
      end
    end

    context 'given an ISBN value that is actually a DOI' do
      let(:isbn_value) { '10.1186/s978-0-596-52068-7-w' }

      it 'returns nil' do
        expect(isbn.isbn).to be_nil
      end
    end
  end
end
