# frozen_string_literal: true

require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/importers/activity_insight_importer'
require_relative '../../../app/models/doi_sanitizer'
require_relative '../../../app/models/issn_sanitizer'
require_relative '../../../app/models/isbn_sanitizer'
require_relative '../../../app/mappers/activity_insight_publication_type_map_in'

describe ActivityInsightPublication do
  let(:parsed_pub) { double 'parsed publication xml' }
  let(:pub) { described_class.new(parsed_pub, user) }
  let(:user) { double 'user', activity_insight_id: 456 }

  describe '#publication_type' do
    before { allow(parsed_pub).to receive(:css).with('CONTYPE').and_return type_element }

    before { allow(parsed_pub).to receive(:css).with('CONTYPEOTHER').and_return type_other_element }

    let(:type_other_element) { nil }

    context 'when the contype element in the given data is empty' do
      let(:type_element) { double 'type element', text: '' }

      it 'returns nil' do
        expect(pub.publication_type).to eq 'Other'
      end
    end

    context "when the contype element in the given data contains 'Journal Article, In House'" do
      let(:type_element) { double 'type element', text: 'Journal Article, In House' }

      it "returns 'In-house Journal Article'" do
        expect(pub.publication_type).to eq 'In-house Journal Article'
      end
    end

    context "when the contype element in the given data contains 'Journal Article'" do
      let(:type_element) { double 'type element', text: 'Journal Article' }

      it "returns 'Journal Article'" do
        expect(pub.publication_type).to eq 'Journal Article'
      end
    end

    context "when the contype element in the given data contains 'Book'" do
      let(:type_element) { double 'type element', text: 'Book' }

      it 'returns Book' do
        expect(pub.publication_type).to eq 'Book'
      end
    end

    context "when the contype element in the given data contains 'Other'" do
      let(:type_element) { double 'type element', text: 'Other' }

      context 'when the contypeother element in the given data is empty' do
        let(:type_other_element) { double 'type other element', text: '' }

        it 'returns nil' do
          expect(pub.publication_type).to eq 'Other'
        end
      end

      context "when the contypeother element in the given data contains 'journal article, academic journal'" do
        let(:type_other_element) { double 'type other element', text: 'journal article, academic journal' }

        it "returns 'Academic Journal Article'" do
          expect(pub.publication_type).to eq 'Academic Journal Article'
        end
      end

      context "when the contypeother element in the given data contains 'Journal Article, Academic Journal'" do
        let(:type_other_element) { double 'type other element', text: 'Journal Article, Academic Journal' }

        it "returns 'Academic Journal Article'" do
          expect(pub.publication_type).to eq 'Academic Journal Article'
        end
      end

      context "when the contypeother element in the given data contains ' journal article, academic journal '" do
        let(:type_other_element) { double 'type other element', text: '  journal article, academic journal  ' }

        it "returns 'Academic Journal Article'" do
          expect(pub.publication_type).to eq 'Academic Journal Article'
        end
      end

      context "when the contypeother element in the given data contains 'journal article, in-house journal'" do
        let(:type_other_element) { double 'type other element', text: 'journal article, in-house journal' }

        it "returns 'In-house Journal Article'" do
          expect(pub.publication_type).to eq 'In-house Journal Article'
        end
      end

      context "when the contypeother element in the given data contains 'Journal Article, In-house Journal'" do
        let(:type_other_element) { double 'type other element', text: 'Journal Article, In-house Journal' }

        it "returns 'In-house Journal Article'" do
          expect(pub.publication_type).to eq 'In-house Journal Article'
        end
      end

      context "when the contypeother element in the given data contains ' journal article, in-house journal '" do
        let(:type_other_element) { double 'type other element', text: '  journal article, in-house journal  ' }

        it "returns 'In-house Journal Article'" do
          expect(pub.publication_type).to eq 'In-house Journal Article'
        end
      end

      context "when the contypeother element in the given data contains 'journal article, in-house'" do
        let(:type_other_element) { double 'type other element', text: 'journal article, in-house' }

        it "returns 'In-house Journal Article'" do
          expect(pub.publication_type).to eq 'In-house Journal Article'
        end
      end

      context "when the contypeother element in the given data contains 'Journal Article, In-house'" do
        let(:type_other_element) { double 'type other element', text: 'Journal Article, In-house' }

        it "returns 'In-house Journal Article'" do
          expect(pub.publication_type).to eq 'In-house Journal Article'
        end
      end

      context "when the contypeother element in the given data contains ' journal article, in-house '" do
        let(:type_other_element) { double 'type other element', text: '  journal article, in-house  ' }

        it "returns 'In-house Journal Article'" do
          expect(pub.publication_type).to eq 'In-house Journal Article'
        end
      end

      context "when the contypeother element in the given data contains 'journal article, professional journal'" do
        let(:type_other_element) { double 'type other element', text: 'journal article, professional journal' }

        it "returns 'Professional Journal Article'" do
          expect(pub.publication_type).to eq 'Professional Journal Article'
        end
      end

      context "when the contypeother element in the given data contains 'Journal Article, Professional Journal'" do
        let(:type_other_element) { double 'type other element', text: 'Journal Article, Professional Journal' }

        it "returns 'Professional Journal Article'" do
          expect(pub.publication_type).to eq 'Professional Journal Article'
        end
      end

      context "when the contypeother element in the given data contains ' journal article, professional journal '" do
        let(:type_other_element) { double 'type other element', text: '  journal article, professional journal  ' }

        it "returns 'Professional Journal Article'" do
          expect(pub.publication_type).to eq 'Professional Journal Article'
        end
      end

      context "when the contypeother element in the given data contains 'journal article, public or trade journal'" do
        let(:type_other_element) { double 'type other element', text: 'journal article, public or trade journal' }

        it "returns 'Trade Journal Article'" do
          expect(pub.publication_type).to eq 'Trade Journal Article'
        end
      end

      context "when the contypeother element in the given data contains 'Journal Article, Public or Trade Journal'" do
        let(:type_other_element) { double 'type other element', text: 'Journal Article, Public or Trade Journal' }

        it "returns 'Trade Journal Article'" do
          expect(pub.publication_type).to eq 'Trade Journal Article'
        end
      end

      context "when the contypeother element in the given data contains ' journal article, public or trade journal '" do
        let(:type_other_element) { double 'type other element', text: '  journal article, public or trade journal  ' }

        it "returns 'Trade Journal Article'" do
          expect(pub.publication_type).to eq 'Trade Journal Article'
        end
      end

      context "when the contypeother element in the given data contains 'magazine or trade journal article'" do
        let(:type_other_element) { double 'type other element', text: 'magazine or trade journal article' }

        it "returns 'Trade Journal Article'" do
          expect(pub.publication_type).to eq 'Trade Journal Article'
        end
      end

      context "when the contypeother element in the given data contains 'Magazine or Trade Journal Article'" do
        let(:type_other_element) { double 'type other element', text: 'Magazine or Trade Journal Article' }

        it "returns 'Trade Journal Article'" do
          expect(pub.publication_type).to eq 'Trade Journal Article'
        end
      end

      context "when the contypeother element in the given data contains ' magazine or trade journal article '" do
        let(:type_other_element) { double 'type other element', text: '  magazine or trade journal article  ' }

        it "returns 'Trade Journal Article'" do
          expect(pub.publication_type).to eq 'Trade Journal Article'
        end
      end

      context "when the contypeother element in the given data contains 'journal article'" do
        let(:type_other_element) { double 'type other element', text: 'journal article' }

        it "returns 'Journal Article'" do
          expect(pub.publication_type).to eq 'Journal Article'
        end
      end

      context "when the contypeother element in the given data contains 'Journal Article'" do
        let(:type_other_element) { double 'type other element', text: 'Journal Article' }

        it "returns 'Journal Article'" do
          expect(pub.publication_type).to eq 'Journal Article'
        end
      end

      context "when the contypeother element in the given data contains ' journal article '" do
        let(:type_other_element) { double 'type other element', text: '  journal article  ' }

        it "returns 'Journal Article'" do
          expect(pub.publication_type).to eq 'Journal Article'
        end
      end

      context "when the contypeother element in the given data contains 'Other'" do
        let(:type_other_element) { double 'type other element', text: 'Other' }

        it 'returns Other' do
          expect(pub.publication_type).to eq 'Other'
        end
      end
    end

    context "when the contype element in the given data contains 'OTHER'" do
      let(:type_element) { double 'type element', text: 'OTHER' }

      context 'when the contypeother element in the given data is empty' do
        let(:type_other_element) { double 'type other element', text: '' }

        it 'returns Other' do
          expect(pub.publication_type).to eq 'Other'
        end
      end
    end
  end

  describe '#status' do
    context 'when a single status element is present' do
      before { allow(parsed_pub).to receive(:css).with('STATUS').and_return([status_element]) }

      context 'when the status element in the given data is empty' do
        let(:status_element) { double 'status element', text: '' }

        it 'returns nil' do
          expect(pub.status).to be_nil
        end
      end

      context 'when the status element in the given data contains text' do
        let(:status_element) { double 'status element', text: "\n     Status  \n   " }

        it 'returns the text with surrounding whitespace removed' do
          expect(pub.status).to eq 'Status'
        end
      end
    end

    context 'when multiple status elements are present' do
      let(:status_element1) { double 'status element', text: "\n     Published  \n   " }
      let(:status_element2) { double 'status element', text: 'Graduate Student' }

      before { allow(parsed_pub).to receive(:css).with('STATUS').and_return([status_element1, status_element2]) }

      it 'returns the first status element' do
        expect(pub.status).to eq 'Published'
      end
    end
  end

  describe '#importable?' do
    before { allow(parsed_pub).to receive(:css).with('STATUS').and_return([status_element]) }

    let(:type_other_element) { nil }

    context "when the status element in the given data does not contain 'Published'" do
      let(:status_element) { double 'status element', text: 'Other Status' }

      it 'returns false' do
        expect(pub.importable?).to be false
      end
    end

    context "when the status element in the given data contains 'Published'" do
      let(:status_element) { double 'status element', text: 'Published' }

      it 'returns true' do
        expect(pub.importable?).to be true
      end
    end
  end

  describe '#activity_insight_id' do
    let(:id_attr) { double 'id attribute', value: '9' }

    before { allow(parsed_pub).to receive(:attribute).with('id').and_return(id_attr) }

    it 'returns the id attribute from the given element' do
      expect(pub.activity_insight_id).to eq '9'
    end
  end

  describe '#title' do
    before { allow(parsed_pub).to receive(:css).with('TITLE').and_return title_element }

    context 'when the title element in the given data is empty' do
      let(:title_element) { double 'title element', text: '' }

      it 'returns nil' do
        expect(pub.title).to be_nil
      end
    end

    context 'when the title element in the given data contains text' do
      let(:title_element) { double 'title element', text: "\n     Title  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(pub.title).to eq 'Title'
      end
    end
  end

  describe '#secondary_title' do
    before { allow(parsed_pub).to receive(:css).with('TITLE_SECONDARY').and_return sub_title_element }

    context 'when the title_secondary element in the given data is empty' do
      let(:sub_title_element) { double 'secondary title element', text: '' }

      it 'returns nil' do
        expect(pub.secondary_title).to be_nil
      end
    end

    context 'when the title_secondary element in the given data contains text' do
      let(:sub_title_element) { double 'secondary title element', text: "\n     Secondary Title  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(pub.secondary_title).to eq 'Secondary Title'
      end
    end
  end

  describe '#journal_title' do
    before { allow(parsed_pub).to receive(:css).with('JOURNAL_NAME').and_return journal_name_element }

    before { allow(parsed_pub).to receive(:css).with('JOURNAL_NAME_OTHER').and_return journal_name_other_element }

    let(:journal_name_other_element) { nil }

    context 'when the journal name element in the given data is empty' do
      let(:journal_name_element) { double 'journal name element', text: '' }

      it 'returns nil' do
        expect(pub.journal_title).to be_nil
      end

      context 'when the journal_name_other element in the given data is empty' do
        let(:journal_name_other_element) { double 'journal name other element', text: '' }

        it 'returns nil' do
          expect(pub.journal_title).to be_nil
        end
      end

      context 'when the journal_name_other element in the given data contains text' do
        let(:journal_name_other_element) { double 'journal name other element', text: "\n     Other Publisher  \n   " }

        it 'returns nil' do
          expect(pub.journal_title).to be_nil
        end
      end
    end

    context 'when the journal name element in the given data contains text' do
      let(:journal_name_element) { double 'journal name element', text: "\n     Publisher  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(pub.journal_title).to eq 'Publisher'
      end

      context 'when the journal_name_other element in the given data is empty' do
        let(:journal_name_other_element) { double 'journal name other element', text: '' }

        it 'returns the text of the journal name element with surrounding whitespace removed' do
          expect(pub.journal_title).to eq 'Publisher'
        end
      end

      context 'when the journal_name_other element in the given data contains text' do
        let(:journal_name_other_element) { double 'journal name other element', text: "\n     Other Publisher  \n   " }

        it 'returns the text of the journal name element with surrounding whitespace removed' do
          expect(pub.journal_title).to eq 'Publisher'
        end
      end
    end

    context "when the journal name element in the given data contains 'other'" do
      let(:journal_name_element) { double 'journal name element', text: 'other' }

      context 'when the journal_name_other element in the given data is empty' do
        let(:journal_name_other_element) { double 'journal name other element', text: '' }

        it 'returns nil' do
          expect(pub.journal_title).to be_nil
        end
      end

      context 'when the journal_name_other element in the given data contains text' do
        let(:journal_name_other_element) { double 'journal name other element', text: "\n     Other Publisher  \n   " }

        it 'returns the text with surrounding whitespace removed' do
          expect(pub.journal_title).to eq 'Other Publisher'
        end
      end
    end

    context "when the journal name element in the given data contains 'Other'" do
      let(:journal_name_element) { double 'journal name element', text: 'Other' }

      context 'when the journal_name_other element in the given data is empty' do
        let(:journal_name_other_element) { double 'journal name other element', text: '' }

        it 'returns nil' do
          expect(pub.journal_title).to be_nil
        end
      end

      context 'when the journal_name_other element in the given data contains text' do
        let(:journal_name_other_element) { double 'journal name other element', text: "\n     Other Publisher  \n   " }

        it 'returns the text with surrounding whitespace removed' do
          expect(pub.journal_title).to eq 'Other Publisher'
        end
      end
    end

    context "when the journal name element in the given data contains ' other '" do
      let(:journal_name_element) { double 'journal name element', text: '  other  ' }

      context 'when the journal_name_other element in the given data is empty' do
        let(:journal_name_other_element) { double 'journal name other element', text: '' }

        it 'returns nil' do
          expect(pub.journal_title).to be_nil
        end
      end

      context 'when the journal_name_other element in the given data contains text' do
        let(:journal_name_other_element) { double 'journal name other element', text: "\n     Other Publisher  \n   " }

        it 'returns the text with surrounding whitespace removed' do
          expect(pub.journal_title).to eq 'Other Publisher'
        end
      end
    end
  end

  describe '#publisher' do
    before { allow(parsed_pub).to receive(:css).with('PUBLISHER').and_return publisher_element }

    before { allow(parsed_pub).to receive(:css).with('PUBLISHER_OTHER').and_return publisher_other_element }

    let(:publisher_other_element) { nil }

    context 'when the publisher element in the given data is empty' do
      let(:publisher_element) { double 'publisher element', text: '' }

      it 'returns nil' do
        expect(pub.publisher).to be_nil
      end

      context 'when the publisher_other element in the given data is empty' do
        let(:publisher_other_element) { double 'publisher other element', text: '' }

        it 'returns nil' do
          expect(pub.publisher).to be_nil
        end
      end

      context 'when the publisher_other element in the given data contains text' do
        let(:publisher_other_element) { double 'publisher other element', text: "\n     Other Publisher  \n   " }

        it 'returns nil' do
          expect(pub.publisher).to be_nil
        end
      end
    end

    context 'when the publisher element in the given data contains text' do
      let(:publisher_element) { double 'publisher element', text: "\n     Publisher  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(pub.publisher).to eq 'Publisher'
      end

      context 'when the publisher_other element in the given data is empty' do
        let(:publisher_other_element) { double 'publisher other element', text: '' }

        it 'returns the text of the publisher element with surrounding whitespace removed' do
          expect(pub.publisher).to eq 'Publisher'
        end
      end

      context 'when the publisher_other element in the given data contains text' do
        let(:publisher_other_element) { double 'publisher other element', text: "\n     Other Publisher  \n   " }

        it 'returns the text of the publisher element with surrounding whitespace removed' do
          expect(pub.publisher).to eq 'Publisher'
        end
      end
    end

    context "when the publisher element in the given data contains 'other'" do
      let(:publisher_element) { double 'publisher element', text: 'other' }

      context 'when the publisher_other element in the given data is empty' do
        let(:publisher_other_element) { double 'publisher other element', text: '' }

        it 'returns nil' do
          expect(pub.publisher).to be_nil
        end
      end

      context 'when the publisher_other element in the given data contains text' do
        let(:publisher_other_element) { double 'publisher other element', text: "\n     Other Publisher  \n   " }

        it 'returns the text with surrounding whitespace removed' do
          expect(pub.publisher).to eq 'Other Publisher'
        end
      end
    end

    context "when the publisher element in the given data contains 'Other'" do
      let(:publisher_element) { double 'publisher element', text: 'Other' }

      context 'when the publisher_other element in the given data is empty' do
        let(:publisher_other_element) { double 'publisher other element', text: '' }

        it 'returns nil' do
          expect(pub.publisher).to be_nil
        end
      end

      context 'when the publisher_other element in the given data contains text' do
        let(:publisher_other_element) { double 'publisher other element', text: "\n     Other Publisher  \n   " }

        it 'returns the text with surrounding whitespace removed' do
          expect(pub.publisher).to eq 'Other Publisher'
        end
      end
    end

    context "when the publisher element in the given data contains ' other '" do
      let(:publisher_element) { double 'publisher element', text: '  other  ' }

      context 'when the publisher_other element in the given data is empty' do
        let(:publisher_other_element) { double 'publisher other element', text: '' }

        it 'returns nil' do
          expect(pub.publisher).to be_nil
        end
      end

      context 'when the publisher_other element in the given data contains text' do
        let(:publisher_other_element) { double 'publisher other element', text: "\n     Other Publisher  \n   " }

        it 'returns the text with surrounding whitespace removed' do
          expect(pub.publisher).to eq 'Other Publisher'
        end
      end
    end
  end

  describe '#volume' do
    before { allow(parsed_pub).to receive(:css).with('VOLUME').and_return volume_element }

    context 'when the volume element in the given data is empty' do
      let(:volume_element) { double 'volume element', text: '' }

      it 'returns nil' do
        expect(pub.volume).to be_nil
      end
    end

    context 'when the volume element in the given data contains text' do
      let(:volume_element) { double 'volume element', text: "\n     Volume  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(pub.volume).to eq 'Volume'
      end
    end
  end

  describe '#issue' do
    before { allow(parsed_pub).to receive(:css).with('ISSUE').and_return issue_element }

    context 'when the issue element in the given data is empty' do
      let(:issue_element) { double 'issue element', text: '' }

      it 'returns nil' do
        expect(pub.issue).to be_nil
      end
    end

    context 'when the issue element in the given data contains text' do
      let(:issue_element) { double 'issue element', text: "\n     Issue  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(pub.issue).to eq 'Issue'
      end
    end
  end

  describe '#edition' do
    before { allow(parsed_pub).to receive(:css).with('EDITION').and_return edition_element }

    context 'when the edition element in the given data is empty' do
      let(:edition_element) { double 'edition element', text: '' }

      it 'returns nil' do
        expect(pub.edition).to be_nil
      end
    end

    context 'when the edition element in the given data contains text' do
      let(:edition_element) { double 'edition element', text: "\n     Edition  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(pub.edition).to eq 'Edition'
      end
    end
  end

  describe '#url' do
    before { allow(parsed_pub).to receive(:css).with('WEB_ADDRESS').and_return url_element }

    context 'when the url element in the given data is empty' do
      let(:url_element) { double 'url element', text: '' }

      it 'returns nil' do
        expect(pub.url).to be_nil
      end
    end

    context 'when the url element in the given data contains text' do
      let(:url_element) { double 'url element', text: "\n     URL  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(pub.url).to eq 'URL'
      end
    end
  end

  describe '#issn' do
    before do
      allow(ISSNSanitizer).to receive(:new).with('ISSN web address').and_return successful_wa_sanitizer
      allow(ISSNSanitizer).to receive(:new).with('non-ISSN web address').and_return unsuccessful_wa_sanitizer
      allow(ISSNSanitizer).to receive(:new).with('ISSN in ISBNISSN').and_return successful_issn_sanitizer
      allow(ISSNSanitizer).to receive(:new).with('non-ISSN in ISBNISSN').and_return unsuccessful_issn_sanitizer
      allow(ISSNSanitizer).to receive(:new).with('ISSN in DOI').and_return successful_doi_sanitizer
      allow(ISSNSanitizer).to receive(:new).with('non-ISSN in DOI').and_return unsuccessful_doi_sanitizer
    end

    let(:successful_wa_sanitizer) { double 'ISSN sanitizer', issn: 'wa ISSN' }
    let(:unsuccessful_wa_sanitizer) { double 'ISSN sanitizer', issn: nil }
    let(:successful_issn_sanitizer) { double 'ISSN sanitizer', issn: 'ISSN' }
    let(:unsuccessful_issn_sanitizer) { double 'ISSN sanitizer', issn: nil }
    let(:successful_doi_sanitizer) { double 'ISSN sanitizer', issn: 'doi ISSN' }
    let(:unsuccessful_doi_sanitizer) { double 'ISSN sanitizer', issn: nil }

    let(:issn_web_address_element) { double 'ISSN web address element', text: 'ISSN web address' }
    let(:non_issn_web_address_element) { double 'non-ISSN web address element', text: 'non-ISSN web address' }
    let(:issn_isbnissn_element) { double 'ISSN isbnissn element', text: 'ISSN in ISBNISSN' }
    let(:non_issn_isbnissn_element) { double 'non-ISSN isbnissn element', text: 'non-ISSN in ISBNISSN' }
    let(:issn_doi_element) { double 'ISSN in doi element', text: 'ISSN in DOI' }
    let(:non_issn_doi_element) { double 'non-ISSN in doi element', text: 'non-ISSN in DOI' }

    context 'when ISSN can be parsed out of the web address element in the given data' do
      before { allow(parsed_pub).to receive(:css).with('WEB_ADDRESS').and_return issn_web_address_element }

      context 'when ISSN can be parsed out of the doi element in the given data' do
        before { allow(parsed_pub).to receive(:css).with('DOI').and_return issn_doi_element }

        context 'when ISSN can be parsed out of the ISBN/ISSN element in the given data' do
          before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return issn_isbnissn_element }

          it 'returns the ISSN from the ISBNISSN element' do
            expect(pub.issn).to eq 'ISSN'
          end
        end

        context 'when ISSN cannot be parsed out of the ISBN/ISSN element' do
          before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return non_issn_isbnissn_element }

          it 'returns the ISSN from the doi element' do
            expect(pub.issn).to eq 'doi ISSN'
          end
        end
      end

      context 'when ISSN cannot be parsed out of the doi element in the given data' do
        before { allow(parsed_pub).to receive(:css).with('DOI').and_return non_issn_doi_element }

        context 'when ISSN can be parsed out of the ISBNISSN element in the given data' do
          before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return issn_isbnissn_element }

          it 'returns the ISSN from the ISBNISSN element' do
            expect(pub.issn).to eq 'ISSN'
          end
        end

        context 'when a ISSN cannot be parsed out of the ISBNISSN element' do
          before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return non_issn_isbnissn_element }

          it 'returns the ISSN from the web_address element' do
            expect(pub.issn).to eq 'wa ISSN'
          end
        end
      end
    end

    context 'when ISSN cannot be parsed out of the web_address element in the given data' do
      before { allow(parsed_pub).to receive(:css).with('WEB_ADDRESS').and_return non_issn_web_address_element }

      context 'when ISSN can be parsed out of the doi element in the given data' do
        before { allow(parsed_pub).to receive(:css).with('DOI').and_return issn_doi_element }

        context 'when ISSN can be parsed out of the ISBNISSN element in the given data' do
          before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return issn_isbnissn_element }

          it 'returns the ISSN from the ISBNISSN element' do
            expect(pub.issn).to eq 'ISSN'
          end
        end

        context 'when ISSN cannot be parsed out of the ISBNISSN element' do
          before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return non_issn_isbnissn_element }

          it 'returns the ISSN from the doi element' do
            expect(pub.issn).to eq 'doi ISSN'
          end
        end
      end

      context 'when ISSN cannot be parsed out of the doi element in the given data' do
        before { allow(parsed_pub).to receive(:css).with('DOI').and_return non_issn_doi_element }

        context 'when ISSN can be parsed out of the ISBNISSN element in the given data' do
          before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return issn_isbnissn_element }

          it 'returns the ISSN from the ISBNISSN element' do
            expect(pub.issn).to eq 'ISSN'
          end
        end

        context 'when ISSN cannot be parsed out of the ISBNISSN element' do
          before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return non_issn_isbnissn_element }

          it 'returns nil' do
            expect(pub.issn).to be_nil
          end
        end
      end
    end
  end

  describe '#isbn' do
    before do
      allow(ISBNSanitizer).to receive(:new).with('ISBN web address').and_return successful_wa_sanitizer
      allow(ISBNSanitizer).to receive(:new).with('non-ISBN web address').and_return unsuccessful_wa_sanitizer
      allow(ISBNSanitizer).to receive(:new).with('ISBN in ISBNISSN').and_return successful_issn_sanitizer
      allow(ISBNSanitizer).to receive(:new).with('non-ISBN in ISBNISSN').and_return unsuccessful_issn_sanitizer
      allow(ISBNSanitizer).to receive(:new).with('ISBN in DOI').and_return successful_doi_sanitizer
      allow(ISBNSanitizer).to receive(:new).with('non-ISBN in DOI').and_return unsuccessful_doi_sanitizer
    end

    let(:successful_wa_sanitizer) { double 'ISBN sanitizer', isbn: 'wa ISBN' }
    let(:unsuccessful_wa_sanitizer) { double 'ISBN sanitizer', isbn: nil }
    let(:successful_issn_sanitizer) { double 'ISBN sanitizer', isbn: 'ISBN' }
    let(:unsuccessful_issn_sanitizer) { double 'ISBN sanitizer', isbn: nil }
    let(:successful_doi_sanitizer) { double 'ISBN sanitizer', isbn: 'doi ISBN' }
    let(:unsuccessful_doi_sanitizer) { double 'ISBN sanitizer', isbn: nil }

    let(:isbn_web_address_element) { double 'ISBN web address element', text: 'ISBN web address' }
    let(:non_isbn_web_address_element) { double 'non-ISBN web address element', text: 'non-ISBN web address' }
    let(:isbn_isbnissn_element) { double 'ISBN isbnissn element', text: 'ISBN in ISBNISSN' }
    let(:non_isbn_isbnissn_element) { double 'non-ISBN isbnissn element', text: 'non-ISBN in ISBNISSN' }
    let(:isbn_doi_element) { double 'ISBN in doi element', text: 'ISBN in DOI' }
    let(:non_isbn_doi_element) { double 'non-ISBN in doi element', text: 'non-ISBN in DOI' }

    context 'when ISBN can be parsed out of the web address element in the given data' do
      before { allow(parsed_pub).to receive(:css).with('WEB_ADDRESS').and_return isbn_web_address_element }

      context 'when ISBN can be parsed out of the doi element in the given data' do
        before { allow(parsed_pub).to receive(:css).with('DOI').and_return isbn_doi_element }

        context 'when ISBN can be parsed out of the ISBN/ISSN element in the given data' do
          before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return isbn_isbnissn_element }

          it 'returns the ISBN from the ISBNISSN element' do
            expect(pub.isbn).to eq 'ISBN'
          end
        end

        context 'when ISBN cannot be parsed out of the ISBN/ISSN element' do
          before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return non_isbn_isbnissn_element }

          it 'returns the ISBN from the doi element' do
            expect(pub.isbn).to eq 'doi ISBN'
          end
        end
      end

      context 'when ISBN cannot be parsed out of the doi element in the given data' do
        before { allow(parsed_pub).to receive(:css).with('DOI').and_return non_isbn_doi_element }

        context 'when ISBN can be parsed out of the ISBNISSN element in the given data' do
          before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return isbn_isbnissn_element }

          it 'returns the ISBN from the ISBNISSN element' do
            expect(pub.isbn).to eq 'ISBN'
          end
        end

        context 'when a ISBN cannot be parsed out of the ISBNISSN element' do
          before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return non_isbn_isbnissn_element }

          it 'returns the ISBN from the web_address element' do
            expect(pub.isbn).to eq 'wa ISBN'
          end
        end
      end
    end

    context 'when ISBN cannot be parsed out of the web_address element in the given data' do
      before { allow(parsed_pub).to receive(:css).with('WEB_ADDRESS').and_return non_isbn_web_address_element }

      context 'when ISBN can be parsed out of the doi element in the given data' do
        before { allow(parsed_pub).to receive(:css).with('DOI').and_return isbn_doi_element }

        context 'when ISBN can be parsed out of the ISBNISSN element in the given data' do
          before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return isbn_isbnissn_element }

          it 'returns the ISBN from the ISBNISSN element' do
            expect(pub.isbn).to eq 'ISBN'
          end
        end

        context 'when ISBN cannot be parsed out of the ISBNISSN element' do
          before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return non_isbn_isbnissn_element }

          it 'returns the ISBN from the doi element' do
            expect(pub.isbn).to eq 'doi ISBN'
          end
        end
      end

      context 'when ISBN cannot be parsed out of the doi element in the given data' do
        before { allow(parsed_pub).to receive(:css).with('DOI').and_return non_isbn_doi_element }

        context 'when ISBN can be parsed out of the ISBNISSN element in the given data' do
          before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return isbn_isbnissn_element }

          it 'returns the ISBN from the ISBNISSN element' do
            expect(pub.isbn).to eq 'ISBN'
          end
        end

        context 'when ISBN cannot be parsed out of the ISBNISSN element' do
          before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return non_isbn_isbnissn_element }

          it 'returns nil' do
            expect(pub.isbn).to be_nil
          end
        end
      end
    end
  end

  describe '#abstract' do
    before { allow(parsed_pub).to receive(:css).with('ABSTRACT').and_return abstract_element }

    context 'when the abstract element in the given data is empty' do
      let(:abstract_element) { double 'abstract element', text: '' }

      it 'returns nil' do
        expect(pub.abstract).to be_nil
      end
    end

    context 'when the abstract element in the given data contains text' do
      let(:abstract_element) { double 'abstract element', text: "\n     Abstract  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(pub.abstract).to eq 'Abstract'
      end
    end
  end

  describe '#page_range' do
    before { allow(parsed_pub).to receive(:css).with('PAGENUM').and_return pagenum_element }

    before { allow(parsed_pub).to receive(:css).with('PUB_PAGENUM').and_return pub_pagenum_element }

    context 'when the pagenum element in the given data is empty' do
      let(:pagenum_element) { double 'pagenum element', text: '' }

      context 'when the pub_pagenum element in the given data is empty' do
        let(:pub_pagenum_element) { double 'pub_pagenum element', text: '' }

        it 'returns nil' do
          expect(pub.page_range).to be_nil
        end
      end

      context 'when the pub_pagenum element in the given data contains text' do
        let(:pub_pagenum_element) { double 'pub_pagenum element', text: "\n     Pub Page Number  \n   " }

        it 'returns the pub_pagenum text with surrounding whitespace removed' do
          expect(pub.page_range).to eq 'Pub Page Number'
        end
      end
    end

    context 'when the pagenum element in the given data contains text' do
      let(:pagenum_element) { double 'pagenum element', text: "\n     Page Number  \n   " }

      context 'when the pub_pagenum element in the given data is empty' do
        let(:pub_pagenum_element) { double 'pub_pagenum element', text: '' }

        it 'returns the pagenum text with surrounding whitespace removed' do
          expect(pub.page_range).to eq 'Page Number'
        end
      end

      context 'when the pub_pagenum element in the given data contains text' do
        let(:pub_pagenum_element) { double 'pub_pagenum element', text: "\n     Pub Page Number  \n   " }

        it 'returns the pagenum text with surrounding whitespace removed' do
          expect(pub.page_range).to eq 'Page Number'
        end
      end
    end
  end

  describe '#authors_et_al' do
    before { allow(parsed_pub).to receive(:css).with('AUTHORS_ETAL').and_return etal_element }

    context 'when the authors_etal element in the given data is empty' do
      let(:etal_element) { double 'authors_etal element', text: '' }

      it 'returns false' do
        expect(pub.authors_et_al).to be false
      end
    end

    context "when the abstract element in the given data contains 'false'" do
      let(:etal_element) { double 'authors_etal element', text: 'false' }

      it 'false' do
        expect(pub.authors_et_al).to be false
      end
    end

    context "when the abstract element in the given data contains 'true'" do
      let(:etal_element) { double 'authors_etal element', text: 'true' }

      it 'true' do
        expect(pub.authors_et_al).to be true
      end
    end

    context "when the abstract element in the given data contains 'TRUE'" do
      let(:etal_element) { double 'authors_etal element', text: 'TRUE' }

      it 'true' do
        expect(pub.authors_et_al).to be true
      end
    end

    context "when the abstract element in the given data contains ' TRUE '" do
      let(:etal_element) { double 'authors_etal element', text: '  TRUE  ' }

      it 'true' do
        expect(pub.authors_et_al).to be true
      end
    end
  end

  describe '#published_on' do
    before { allow(parsed_pub).to receive(:css).with('PUB_START').and_return pub_start_element }

    context 'when the pub_start element in the given data is empty' do
      let(:pub_start_element) { double 'pub_start element', text: '' }

      it 'returns nil' do
        expect(pub.published_on).to be_nil
      end
    end

    context 'when the pub_start element in the given data contains text' do
      let(:pub_start_element) { double 'pub_start element', text: "\n     Pub Start  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(pub.published_on).to eq 'Pub Start'
      end
    end
  end

  describe '#doi' do
    before do
      allow(DOISanitizer).to receive(:new).with('a DOI web address').and_return successful_wa_sanitizer
      allow(DOISanitizer).to receive(:new).with('a non-DOI web address').and_return unsuccessful_wa_sanitizer
      allow(DOISanitizer).to receive(:new).with('a DOI ISSN/ISBN').and_return successful_issn_sanitizer
      allow(DOISanitizer).to receive(:new).with('a non-DOI ISSN/ISBN').and_return unsuccessful_issn_sanitizer
      allow(DOISanitizer).to receive(:new).with('a DOI').and_return successful_doi_sanitizer
      allow(DOISanitizer).to receive(:new).with('an invalid DOI').and_return unsuccessful_doi_sanitizer
    end

    let(:successful_wa_sanitizer) { double 'DOI sanitizer', url: 'wa DOI' }
    let(:unsuccessful_wa_sanitizer) { double 'DOI sanitizer', url: nil }
    let(:successful_issn_sanitizer) { double 'DOI sanitizer', url: 'ISSN DOI' }
    let(:unsuccessful_issn_sanitizer) { double 'DOI sanitizer', url: nil }
    let(:successful_doi_sanitizer) { double 'DOI sanitizer', url: 'DOI' }
    let(:unsuccessful_doi_sanitizer) { double 'DOI sanitizer', url: nil }

    let(:doi_web_address_element) { double 'DOI web address element', text: 'a DOI web address' }
    let(:non_doi_web_address_element) { double 'non-DOI web address element', text: 'a non-DOI web address' }
    let(:doi_isbnissn_element) { double 'DOI isbnissn element', text: 'a DOI ISSN/ISBN' }
    let(:non_doi_isbnissn_element) { double 'non-DOI isbnissn element', text: 'a non-DOI ISSN/ISBN' }
    let(:doi_element) { double 'DOI element', text: 'a DOI' }
    let(:invalid_doi_element) { double 'invalid DOI element', text: 'an invalid DOI' }

    context 'when a DOI can be parsed out of the web_address element in the given data' do
      before { allow(parsed_pub).to receive(:css).with('WEB_ADDRESS').and_return doi_web_address_element }

      context 'when a DOI can be parsed out of the isbnissn element in the given data' do
        before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return doi_isbnissn_element }

        context 'when a DOI can be parsed out of the DOI element in the given data' do
          before { allow(parsed_pub).to receive(:css).with('DOI').and_return doi_element }

          it 'returns the DOI from the DOI element' do
            expect(pub.doi).to eq 'DOI'
          end
        end

        context 'when a DOI cannot be parsed out of the DOI element' do
          before { allow(parsed_pub).to receive(:css).with('DOI').and_return invalid_doi_element }

          it 'returns the DOI from the web_address element' do
            expect(pub.doi).to eq 'wa DOI'
          end
        end
      end

      context 'when a DOI cannot be parsed out of the isbnissn element in the given data' do
        before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return non_doi_isbnissn_element }

        context 'when a DOI can be parsed out of the DOI element in the given data' do
          before { allow(parsed_pub).to receive(:css).with('DOI').and_return doi_element }

          it 'returns the DOI from the DOI element' do
            expect(pub.doi).to eq 'DOI'
          end
        end

        context 'when a DOI cannot be parsed out of the DOI element' do
          before { allow(parsed_pub).to receive(:css).with('DOI').and_return invalid_doi_element }

          it 'returns the DOI from the web_address element' do
            expect(pub.doi).to eq 'wa DOI'
          end
        end
      end
    end

    context 'when a DOI cannot be parsed out of the web_address element in the given data' do
      before { allow(parsed_pub).to receive(:css).with('WEB_ADDRESS').and_return non_doi_web_address_element }

      context 'when a DOI can be parsed out of the isbnissn element in the given data' do
        before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return doi_isbnissn_element }

        context 'when a DOI can be parsed out of the DOI element in the given data' do
          before { allow(parsed_pub).to receive(:css).with('DOI').and_return doi_element }

          it 'returns the DOI from the DOI element' do
            expect(pub.doi).to eq 'DOI'
          end
        end

        context 'when a DOI cannot be parsed out of the DOI element' do
          before { allow(parsed_pub).to receive(:css).with('DOI').and_return invalid_doi_element }

          it 'returns the DOI from the isbnissn element' do
            expect(pub.doi).to eq 'ISSN DOI'
          end
        end
      end

      context 'when a DOI cannot be parsed out of the isbnissn element in the given data' do
        before { allow(parsed_pub).to receive(:css).with('ISBNISSN').and_return non_doi_isbnissn_element }

        context 'when a DOI can be parsed out of the DOI element in the given data' do
          before { allow(parsed_pub).to receive(:css).with('DOI').and_return doi_element }

          it 'returns the DOI from the DOI element' do
            expect(pub.doi).to eq 'DOI'
          end
        end

        context 'when a DOI cannot be parsed out of the DOI element' do
          before { allow(parsed_pub).to receive(:css).with('DOI').and_return invalid_doi_element }

          it 'returns nil' do
            expect(pub.doi).to be_nil
          end
        end
      end
    end
  end

  describe '#faculty_author' do
    let(:auth_element1) { double 'XML element 1' }
    let(:auth_element2) { double 'XML element 2' }
    let(:auth_element3) { double 'XML element 3' }
    let(:auth1) { double 'author 1', activity_insight_user_id: 123 }
    let(:auth2) { double 'author 2', activity_insight_user_id: 456 }
    let(:auth3) { double 'author 3', activity_insight_user_id: nil }

    before do
      allow(parsed_pub).to receive(:css).with('INTELLCONT_AUTH').and_return([auth_element1,
                                                                             auth_element2,
                                                                             auth_element3])
      allow(ActivityInsightPublicationAuthor).to receive(:new).with(auth_element1, user).and_return(auth1)
      allow(ActivityInsightPublicationAuthor).to receive(:new).with(auth_element2, user).and_return(auth2)
      allow(ActivityInsightPublicationAuthor).to receive(:new).with(auth_element3, user).and_return(auth3)
    end

    it "returns an array of the publication's authors from the given data who have a user ID" do
      expect(pub.faculty_author).to eq auth2
    end
  end

  describe '#contributors' do
    let(:auth_element1) { double 'XML element 1' }
    let(:auth_element2) { double 'XML element 2' }
    let(:auth_element3) { double 'XML element 3' }
    let(:auth1) { double 'author 1', activity_insight_user_id: 123 }
    let(:auth2) { double 'author 2', activity_insight_user_id: 456 }
    let(:auth3) { double 'author 3', activity_insight_user_id: nil }

    before do
      allow(parsed_pub).to receive(:css).with('INTELLCONT_AUTH').and_return([auth_element1,
                                                                             auth_element2,
                                                                             auth_element3])
      allow(ActivityInsightPublicationAuthor).to receive(:new).with(auth_element1, user).and_return(auth1)
      allow(ActivityInsightPublicationAuthor).to receive(:new).with(auth_element2, user).and_return(auth2)
      allow(ActivityInsightPublicationAuthor).to receive(:new).with(auth_element3, user).and_return(auth3)
    end

    it "returns an array of the publication's authors from the given data" do
      expect(pub.contributors).to eq [auth1, auth2, auth3]
    end
  end
end
