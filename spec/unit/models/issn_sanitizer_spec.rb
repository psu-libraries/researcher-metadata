# frozen_string_literal: true

require 'unit/unit_spec_helper'
require_relative '../../../app/models/issn_sanitizer'
require_relative '../../../app/models/isbn_sanitizer'
require_relative '../../../app/models/doi_sanitizer'

describe ISSNSanitizer do
  let(:issn_value) { nil }
  let(:issn) { described_class.new(issn_value) }

  describe '#issn' do
    context 'given a nil value' do
      it 'returns nil' do
        expect(issn.issn).to be_nil
      end
    end

    context 'given an empty string value' do
      let(:issn_value) { '' }

      it 'returns nil' do
        expect(issn.issn).to be_nil
      end
    end

    context 'given a blank string value' do
      let(:issn_value) { ' ' }

      it 'returns nil' do
        expect(issn.issn).to be_nil
      end
    end

    context 'given a valid ISSN' do
      let(:issn_value) { '1234-9876' }

      it 'returns the ISSN' do
        expect(issn.issn).to eq '1234-9876'
      end
    end

    context 'given a valid ISSN with an X at the end' do
      let(:issn_value) { '1234-987X' }

      it 'returns the ISSN' do
        expect(issn.issn).to eq '1234-987X'
      end
    end

    context 'given a valid ISSN with ISSN prefix' do
      let(:issn_value) { 'ISSN 1234-9876' }

      it 'returns the ISSN' do
        expect(issn.issn).to eq 'ISSN 1234-9876'
      end
    end

    context 'given a valid ISSN with eISSN prefix' do
      let(:issn_value) { 'eISSN 1234-9876' }

      it 'returns the ISSN' do
        expect(issn.issn).to eq 'eISSN 1234-9876'
      end
    end

    context 'given an ISSN value without a -' do
      let(:issn_value) { '12349876' }

      it 'returns nil' do
        expect(issn.issn).to be_nil
      end
    end

    context 'given an ISSN value that is missing digits' do
      let(:issn_value) { '1234-987' }

      it 'returns nil' do
        expect(issn.issn).to be_nil
      end
    end

    context 'given an ISSN value with letters' do
      let(:issn_value) { '12AB-9876' }

      it 'returns nil' do
        expect(issn.issn).to be_nil
      end
    end

    context 'given an ISSN value that is actually an ISBN' do
      let(:issn_value) { '978-0596-52068-7' }

      it 'returns nil' do
        expect(issn.issn).to be_nil
      end
    end

    context 'given an ISSN value that is actually a DOI' do
      let(:issn_value) { '10.1186/s40543-02000348-w' }

      it 'returns nil' do
        expect(issn.issn).to be_nil
      end
    end
  end
end
