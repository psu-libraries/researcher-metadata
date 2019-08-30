require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/importers/web_of_science_publication'
require_relative '../../../app/models/wos_author_name'
require_relative '../../../app/models/wos_grant'
require_relative '../../../app/models/wos_contributor'

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
    let(:full_name) { double 'full name', text: "  \n Full Name  \n\n " }
    let(:wos_name) { double 'WOS author name' }

    before do
      allow(WOSAuthorName).to receive(:new).with('Full Name').and_return(wos_name)
      allow(parsed_pub).to receive(:css).with('summary > names > name[role="author"]').and_return([full_name])
    end

    it "returns an array of the names of the publication's authors" do
      expect(pub.author_names).to eq [wos_name]
    end
  end

  describe '#grants' do
    let(:grant_element1) { double 'grant element 1' }
    let(:grant_element2) { double 'grant element 2' }
    let(:grant1) { double 'grant 1' }
    let(:grant2) { double 'grant 2' }

    before do
      allow(WOSGrant).to receive(:new).with(grant_element1).and_return(grant1)
      allow(WOSGrant).to receive(:new).with(grant_element2).and_return(grant2)
      allow(parsed_pub).to receive(:css).with('grants > grant').and_return([grant_element1, grant_element2])
    end

    it "returns an array of the grants associated with the publication" do
      expect(pub.grants).to eq [grant1, grant2]
    end
  end

  describe '#contributors' do
    let(:cont_element1) { double 'contributor element 1' }
    let(:cont_element2) { double 'contributor element 2' }
    let(:cont1) { double 'contributor 1' }
    let(:cont2) { double 'contributor 2' }

    before do
      allow(WOSContributor).to receive(:new).with(cont_element1).and_return(cont1)
      allow(WOSContributor).to receive(:new).with(cont_element2).and_return(cont2)
      allow(parsed_pub).to receive(:css).with('contributors > contributor').and_return([cont_element1, cont_element2])
    end

    it "returns an array of the contributors associated with the publication" do
      expect(pub.contributors).to eq [cont1, cont2]
    end
  end
end
