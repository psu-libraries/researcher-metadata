require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/importers/activity_insight_publication'
require_relative '../../../app/models/doi_parser'

describe ActivityInsightPublication do
  let(:publication_row) { {} }
  let(:pub) { ActivityInsightPublication.new(publication_row) }

  describe '#doi' do
    context "when the given data has no web address 1 value" do
      context "when the given data has no ISBN/ISSN value" do
        it "returns nil" do
          expect(pub.doi).to be_nil
        end
      end

      context "when the given data has an ISBN/ISSN value that does not contain a DOI" do
        before { publication_row[:isbnissn] = 'not a doi' }
        it "returns nil" do
          expect(pub.doi).to be_nil
        end
      end

      context "when the given data has an ISBN/ISSN value that is a properly formatted DOI URL" do
        before { publication_row[:isbnissn] = 'https://doi.org/10.1016/S0962-1849(05)80014-9' }
        it "returns the DOI URL from the ISBN/ISSN field" do
          expect(pub.doi).to eq 'https://doi.org/10.1016/S0962-1849(05)80014-9'
        end
      end
    end

    context "when the given data has a web address 1 value that is not a DOI" do
      before { publication_row[:web_address] = 'not a doi' }
      context "when the given data has no ISBN/ISSN value" do
        it "returns nil" do
          expect(pub.doi).to be_nil
        end
      end

      context "when the given data has an ISBN/ISSN value that does not contain a DOI" do
        before { publication_row[:isbnissn] = 'not a doi' }
        it "returns nil" do
          expect(pub.doi).to be_nil
        end
      end

      context "when the given data has an ISBN/ISSN value that is a properly formatted DOI URL" do
        before { publication_row[:isbnissn] = 'https://doi.org/10.1016/S0962-1849(05)80014-9' }
        it "returns the DOI URL from the ISBN/ISSN field" do
          expect(pub.doi).to eq 'https://doi.org/10.1016/S0962-1849(05)80014-9'
        end
      end
    end

    context "when the given data has a web address 1 value that is a properly formatted DOI URL" do
      before { publication_row[:web_address] = 'https://doi.org/10.1001/archderm.139.10.1363-g' }
      context "when the given data has no ISBN/ISSN value" do
        it "returns the DOI URL from the web address 1 field" do
          expect(pub.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
        end
      end

      context "when the given data has an ISBN/ISSN value that does not contain a DOI" do
        before { publication_row[:isbnissn] = 'not a doi' }
        it "returns the DOI URL from the web address 1 field" do
          expect(pub.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
        end
      end

      context "when the given data has an ISBN/ISSN value that is a properly formatted DOI URL" do
        before { publication_row[:isbnissn] = 'https://doi.org/10.1016/S0962-1849(05)80014-9' }
        it "returns the DOI URL from the web address 1 field" do
          expect(pub.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
        end
      end
    end



    context "when the given data has no web address 2 value" do
      context "when the given data has no ISBN/ISSN value" do
        it "returns nil" do
          expect(pub.doi).to be_nil
        end
      end

      context "when the given data has an ISBN/ISSN value that does not contain a DOI" do
        before { publication_row[:isbnissn] = 'not a doi' }
        it "returns nil" do
          expect(pub.doi).to be_nil
        end
      end

      context "when the given data has an ISBN/ISSN value that is a properly formatted DOI URL" do
        before { publication_row[:isbnissn] = 'https://doi.org/10.1016/S0962-1849(05)80014-9' }
        it "returns the DOI URL from the ISBN/ISSN field" do
          expect(pub.doi).to eq 'https://doi.org/10.1016/S0962-1849(05)80014-9'
        end
      end
    end

    context "when the given data has a web address 2 value that is not a DOI" do
      before { publication_row[:web_address2] = 'not a doi' }
      context "when the given data has no ISBN/ISSN value" do
        it "returns nil" do
          expect(pub.doi).to be_nil
        end
      end

      context "when the given data has an ISBN/ISSN value that does not contain a DOI" do
        before { publication_row[:isbnissn] = 'not a doi' }
        it "returns nil" do
          expect(pub.doi).to be_nil
        end
      end

      context "when the given data has an ISBN/ISSN value that is a properly formatted DOI URL" do
        before { publication_row[:isbnissn] = 'https://doi.org/10.1016/S0962-1849(05)80014-9' }
        it "returns the DOI URL from the ISBN/ISSN field" do
          expect(pub.doi).to eq 'https://doi.org/10.1016/S0962-1849(05)80014-9'
        end
      end
    end

    context "when the given data has a web address 2 value that is a properly formatted DOI URL" do
      before { publication_row[:web_address2] = 'https://doi.org/10.1001/archderm.139.10.1363-g' }
      context "when the given data has no ISBN/ISSN value" do
        it "returns the DOI URL from the web address 2 field" do
          expect(pub.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
        end
      end

      context "when the given data has an ISBN/ISSN value that does not contain a DOI" do
        before { publication_row[:isbnissn] = 'not a doi' }
        it "returns the DOI URL from the web address 2 field" do
          expect(pub.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
        end
      end

      context "when the given data has an ISBN/ISSN value that is a properly formatted DOI URL" do
        before { publication_row[:isbnissn] = 'https://doi.org/10.1016/S0962-1849(05)80014-9' }
        it "returns the DOI URL from the web address 2 field" do
          expect(pub.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
        end
      end
    end



    context "when the given data has no web address 3 value" do
      context "when the given data has no ISBN/ISSN value" do
        it "returns nil" do
          expect(pub.doi).to be_nil
        end
      end

      context "when the given data has an ISBN/ISSN value that does not contain a DOI" do
        before { publication_row[:isbnissn] = 'not a doi' }
        it "returns nil" do
          expect(pub.doi).to be_nil
        end
      end

      context "when the given data has an ISBN/ISSN value that is a properly formatted DOI URL" do
        before { publication_row[:isbnissn] = 'https://doi.org/10.1016/S0962-1849(05)80014-9' }
        it "returns the DOI URL from the ISBN/ISSN field" do
          expect(pub.doi).to eq 'https://doi.org/10.1016/S0962-1849(05)80014-9'
        end
      end
    end

    context "when the given data has a web address 3 value that is not a DOI" do
      before { publication_row[:web_address3] = 'not a doi' }
      context "when the given data has no ISBN/ISSN value" do
        it "returns nil" do
          expect(pub.doi).to be_nil
        end
      end

      context "when the given data has an ISBN/ISSN value that does not contain a DOI" do
        before { publication_row[:isbnissn] = 'not a doi' }
        it "returns nil" do
          expect(pub.doi).to be_nil
        end
      end

      context "when the given data has an ISBN/ISSN value that is a properly formatted DOI URL" do
        before { publication_row[:isbnissn] = 'https://doi.org/10.1016/S0962-1849(05)80014-9' }
        it "returns the DOI URL from the ISBN/ISSN field" do
          expect(pub.doi).to eq 'https://doi.org/10.1016/S0962-1849(05)80014-9'
        end
      end
    end

    context "when the given data has a web address 3 value that is a properly formatted DOI URL" do
      before { publication_row[:web_address3] = 'https://doi.org/10.1001/archderm.139.10.1363-g' }
      context "when the given data has no ISBN/ISSN value" do
        it "returns the DOI URL from the web address 3 field" do
          expect(pub.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
        end
      end

      context "when the given data has an ISBN/ISSN value that does not contain a DOI" do
        before { publication_row[:isbnissn] = 'not a doi' }
        it "returns the DOI URL from the web address 3 field" do
          expect(pub.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
        end
      end

      context "when the given data has an ISBN/ISSN value that is a properly formatted DOI URL" do
        before { publication_row[:isbnissn] = 'https://doi.org/10.1016/S0962-1849(05)80014-9' }
        it "returns the DOI URL from the web address 3 field" do
          expect(pub.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
        end
      end
    end
  end
end
