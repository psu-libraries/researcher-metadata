require 'unit/unit_spec_helper'
require_relative '../../../app/models/doi_sanitizer'

describe DOISanitizer do
  let(:doi_value) { nil }
  let(:doi) { DOISanitizer.new(doi_value) }

  describe '#url' do
    context 'given a nil value' do
      it 'returns nil' do
        expect(doi.url).to be_nil
      end
    end

    context 'given an empty string value' do
      let(:doi_value) { '' }

      it 'returns nil' do
        expect(doi.url).to be_nil
      end
    end

    context 'given a blank string value' do
      let(:doi_value) { ' ' }

      it 'returns nil' do
        expect(doi.url).to be_nil
      end
    end

    context 'given a partial URL that does not contain a DOI' do
      let(:doi_value) { 'www.sciencedirect.com/science/article/pii/S0921509312010118' }

      it 'returns nil' do
        expect(doi.url).to be_nil
      end
    end

    context 'given an ISSN' do
      let(:doi_value) { '1054-853X' }

      it 'returns nil' do
        expect(doi.url).to be_nil
      end
    end

    context 'given a valid DOI string' do
      let(:doi_value) { '10.1017/S1369415413000277' }

      it 'returns a full DOI URL' do
        expect(doi.url).to eq 'https://doi.org/10.1017/S1369415413000277'
      end
    end

    context 'given a valid DOI URL value' do
      let(:doi_value) { 'https://doi.org/10.1001/archderm.139.10.1363-g' }

      it 'returns the URL' do
        expect(doi.url).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
      end
    end

    context 'given a valid DOI URL surrounded by some other text' do
      let(:doi_value) { 'some junk https://doi.org/10.1001/archderm.139.10.1363-g more junk' }

      it 'returns the URL' do
        expect(doi.url).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
      end
    end

    context 'given a DOI URL that is missing the scheme' do
      let(:doi_value) { 'doi.org/10.1001/archderm.139.10.1363-g' }

      it 'returns a full URL' do
        expect(doi.url).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
      end
    end

    context 'given a partial older-style of DOI URL' do
      let(:doi_value) { 'dx.doi.org/10.1155/2013/603791' }

      it 'returns a full URL' do
        expect(doi.url).to eq 'https://doi.org/10.1155/2013/603791'
      end
    end

    context 'given a DOI with a lower case prefix plus whitespace' do
      let(:doi_value) { 'doi: 10.1177/2041669518755806' }

      it 'returns a full URL' do
        expect(doi.url).to eq 'https://doi.org/10.1177/2041669518755806'
      end
    end

    context 'given a DOI with an upper case prefix and no whitespace' do
      let(:doi_value) { 'DOI:10.1038/s41598-017-15495-2' }

      it 'returns a full URL' do
        expect(doi.url).to eq 'https://doi.org/10.1038/s41598-017-15495-2'
      end
    end

    context 'given a DOI URL that has some preceeding whitespace characters' do
      let(:doi_value) { "  \thttps://doi.org/10.1038/s41598-017-15495-2" }

      it 'returns the URL with the whitespace stripped off' do
        expect(doi.url).to eq 'https://doi.org/10.1038/s41598-017-15495-2'
      end
    end

    context 'given a DOI URL that contains a non-printing space character' do
      let(:doi_value) { "https://doi.org/10.1038/s\u200b41598-017-15495-2" }

      it 'returns the URL with the non-printing space character removed' do
        expect(doi.url).to eq 'https://doi.org/10.1038/s41598-017-15495-2'
      end
    end

    context 'given a DOI URL that contains a non-ASCII dash character' do
      let(:doi_value) { "https://doi.org/10.1038/s41598\u2013017-15495-2" }

      it 'returns the URL with the non-ASCII dash replaced with a hyphen' do
        expect(doi.url).to eq 'https://doi.org/10.1038/s41598-017-15495-2'
      end
    end
  end
end
