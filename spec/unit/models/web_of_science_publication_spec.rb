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
    before do
      allow(parsed_pub).to receive(:css).with('dynamic_data > cluster_related > identifiers > identifier[type="doi"]').and_return [doi]
      allow(parsed_pub).to receive(:css).with('dynamic_data > cluster_related > identifiers > identifier[type="xref_doi"]').and_return [xref_doi]
    end

    context "when the given data does not have an xref DOI identifier element" do
      let(:xref_doi) { nil }

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

    context "when the given data has an xref DOI identifier element" do
      let(:xref_doi) { {value: " \n   10.2000/XREFDOI456  \n "}}
      context "when the given data has a DOI identifier element" do
        let(:doi) { {value: "\n    10.1000/DOI123  \n   "} }
        it "returns the value of the DOI with any whitespace removed" do
          expect(pub.doi).to eq '10.1000/DOI123'
        end
      end

      context "when the given data does not have a DOI identifier element" do
        let(:doi) { nil }
        it "returns the value of the xref DOI identifier with any whitespace removed" do
          expect(pub.doi).to eq '10.2000/XREFDOI456'
        end
      end
    end
  end

  describe '#issn' do
    before do
      allow(parsed_pub).to receive(:css).with('dynamic_data > cluster_related > identifiers > identifier[type="issn"]').and_return [issn]
    end
    context "when the given data has an ISSN identifier element" do
      let(:issn) { {value: "\n    1234-5678  \n   "} }
      it "returns the value of the ISSN with any whitespace removed" do
        expect(pub.issn).to eq '1234-5678'
      end
    end

    context "when the given data does not have an ISSN identifier element" do
      let(:issn) { nil }
      it "returns nil" do
        expect(pub.issn).to eq nil
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

  describe '#journal_title' do
    let(:title_element) { double 'title element', text: "   \n Journal Title  \n"}
    before { allow(parsed_pub).to receive(:css).with('title[type="source"]').and_return(title_element) }

    it "returns the title of the publication's journal with any surrounding whitespace removed" do
      expect(pub.journal_title).to eq "Journal Title"
    end
  end

  describe '#issue' do
    let(:info_element) { double 'pub info element' }
    before do
      allow(parsed_pub).to receive(:css).with('pub_info').and_return info_element
      allow(info_element).to receive(:attribute).with('issue').and_return issue_attr
    end

    context "when the given data contains an issue number" do
      let(:issue_attr) { double 'issue attribute', value: "17" }
      it "returns the publication's issue number" do
        expect(pub.issue).to eq "17"
      end
    end
    context "when the given data does not contain an issue number" do
      let(:issue_attr) { nil }
      it "returns nil" do
        expect(pub.issue).to eq nil
      end
    end
  end

  describe '#volume' do
    let(:info_element) { double 'pub info element' }
    before do
      allow(parsed_pub).to receive(:css).with('pub_info').and_return info_element
      allow(info_element).to receive(:attribute).with('vol').and_return volume_attr
    end

    context "when the given data contains a volume number" do
      let(:volume_attr) { double 'volume attribute', value: "25" }
      it "returns the publication's volume number" do
        expect(pub.volume).to eq "25"
      end
    end
    context "when the given data does not contain a volume number" do
      let(:volume_attr) { nil }
      it "returns nil" do
        expect(pub.volume).to eq nil
      end
    end
  end

  describe '#page_range' do
    let(:page_element) { double 'page element', text: "  \n 102-111 \n  " }
    before do
      allow(parsed_pub).to receive(:css).with('pub_info > page').and_return page_element
    end

    it "returns the publication's page numbers with any surrounding whitespace removed" do
      expect(pub.page_range).to eq "102-111"
    end
  end

  describe '#publisher' do
    let(:publisher_name_element) { double 'publisher name element', text: "  \n Test Publisher\n "}
    before do
      allow(parsed_pub).to receive(:css).with('publishers > publisher > names > name[role="publisher"] > full_name').
        and_return(publisher_name_element)
    end

    it "returns the name of the publication's publisher with any surrounding whitespace removed" do
      expect(pub.publisher).to eq "Test Publisher"
    end
  end

  describe '#publication_date' do
    let(:info_element) { double 'pub info element' }
    before do
      allow(parsed_pub).to receive(:css).with('pub_info').and_return info_element
      allow(info_element).to receive(:attribute).with('sortdate').and_return date_attr
    end

    context "when the given data contains a date of publication" do
      let(:date_attr) { double 'date attribute', value: "2003-05-27" }
      it "returns the publication's date" do
        expect(pub.publication_date).to eq Date.new(2003, 5, 27)
      end
    end
    context "when the given data does not contain a date of publication" do
      let(:date_attr) { nil }
      it "returns nil" do
        expect(pub.publication_date).to eq nil
      end
    end
  end

  describe '#author_names' do
    let(:name_element) { double 'name element' }
    let(:wos_name) { double 'WOS author name' }
    let(:full_name_element) { double 'full name element', text: 'Full Name'}

    before do
      allow(WOSAuthorName).to receive(:new).with('Full Name').and_return(wos_name)
      allow(parsed_pub).to receive(:css).with('summary > names > name[role="author"]').and_return([name_element])
      allow(name_element).to receive(:css).with('full_name').and_return full_name_element
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

  describe '#orcids' do
    let(:cont_element1) { double 'contributor element 1' }
    let(:cont_element2) { double 'contributor element 2' }
    let(:cont1) { double 'contributor 1', orcid: nil }
    let(:cont2) { double 'contributor 2', orcid: '1234' }

    before do
      allow(WOSContributor).to receive(:new).with(cont_element1).and_return(cont1)
      allow(WOSContributor).to receive(:new).with(cont_element2).and_return(cont2)
      allow(parsed_pub).to receive(:css).with('contributors > contributor').and_return([cont_element1, cont_element2])
    end

    it "returns an array of the orcids for contributors associated with the publication" do
      expect(pub.orcids).to eq ['1234']
    end
  end
end
