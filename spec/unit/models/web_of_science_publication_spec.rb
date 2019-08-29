require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/importers/web_of_science_publication'

describe WebOfSciencePublication do
  let(:parsed_pub) { double 'parsed publication xml' }
  let(:pub) { WebOfSciencePublication.new(parsed_pub) }

  describe '#title' do
    before { allow(parsed_pub).to receive(:css).with('title[type="item"]').and_return [title_element] }

    context "when the Title element in the given data is empty" do
      let(:title_element) { double 'title element', text: '' }
      it "returns nil" do
        expect(pub.title).to be_nil
      end
    end

    context "when the Title element in the given data contains text" do
      let(:title_element) { double 'title element', text: "\n     Title  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(pub.title).to eq 'Title'
      end
    end
  end

  describe '#importable?' do
    let(:address) { double 'address' }
    before do
      allow(parsed_pub).to receive(:css).with('doctypes > doctype').and_return doctypes
      allow(parsed_pub).to receive(:css).with('addresses').and_return [address]
      allow(address).to receive(:css).with('address_name > address_spec > organizations').and_return [organization]
    end

    context "when the given data includes a doctype of 'Article'" do
      let(:doctypes) { [double('doctype', text: 'Article')] }

      context "when the given data has an address with an organization called 'Penn State Univ'" do
        let(:organization) { double 'organization', text: 'Penn State Univ' }
        it "returns true" do
          expect(pub.importable?).to eq true
        end
      end

      context "when the given data has an address with an organization called 'Penn State University'" do
        let(:organization) { double 'organization', text: 'Penn State University' }
        it "returns true" do
          expect(pub.importable?).to eq true
        end
      end

      context "when the given data has an address with an organization called 'Other Univ'" do
        let(:organization) { double 'organization', text: 'Other Univ' }
        it "returns false" do
          expect(pub.importable?).to eq false
        end
      end
    end

    context "when the given data does not include a doctype of 'Article'" do
      let(:doctypes) { [double('doctype', text: 'Other')] }
      context "when the given data has an address with an organization called 'Penn State Univ'" do
        let(:organization) { double 'organization', text: 'Penn State Univ' }
        it "returns false" do
          expect(pub.importable?).to eq false
        end
      end

      context "when the given data has an address with an organization called 'Penn State University'" do
        let(:organization) { double 'organization', text: 'Penn State University' }
        it "returns false" do
          expect(pub.importable?).to eq false
        end
      end

      context "when the given data has an address with an organization called 'Other Univ'" do
        let(:organization) { double 'organization', text: 'Other Univ' }
        it "returns false" do
          expect(pub.importable?).to eq false
        end
      end
    end
  end

  describe '#doi' do
    before { allow(parsed_pub).to receive(:css).with('dynamic_data > cluster_related > identifiers > identifier[type="doi"]').and_return [doi] }

    context "when the given data has a DOI identifier element" do
      let(:doi) { {value: "\n    10.1000/DOI123  \n   "} }
      it "returns the value of the DOI with any whitespace removed" do
        expect(pub.doi).to eq '10.1000/DOI123'
      end
    end

    context "when the given data does not have a DOI identifier element" do
      let(:doi) { nil }
      it "returns nil" do
        expect(pub.doi).to eq nil
      end
    end
  end

  describe '#abstract' do
    before { allow(parsed_pub).to receive(:css).with('abstracts > abstract > abstract_text').and_return abstracts }

    context "when there are no abstract text elements" do
      let(:abstracts) { [] }
      it "returns nil" do
        expect(pub.abstract).to eq nil
      end
    end
    context "when there is one abstract text element" do
      let(:abstracts) { [double('abstract1', text: "  \n first abstract \n   ")] }
      it "returns the text with any surrounding whitespace removed" do
        expect(pub.abstract).to eq 'first abstract'
      end
    end
    context "when there are two abstract text elements" do
      let(:abstracts) { [double('abstract1', text: "  \n first abstract \n   "),
                         double('abstract2', text: " \n    second abstract  \n\n ")] }

      it "returns the text of the two elements separated by a blank line with any surrounding whitespace removed" do
        expect(pub.abstract).to eq "first abstract\n\nsecond abstract"
      end
    end
  end

  describe '#author_names' do

  end
end
