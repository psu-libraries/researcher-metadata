require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/importers/activity_insight_importer'
require_relative '../../../app/models/doi_parser'

describe ActivityInsightAPIPublication do
  let(:parsed_pub) { double 'parsed publication xml' }
  let(:pub) { ActivityInsightAPIPublication.new(parsed_pub) }

  describe '#publication_type' do
    before { allow(parsed_pub).to receive(:css).with('CONTYPE').and_return type_element }
    before { allow(parsed_pub).to receive(:css).with('CONTYPEOTHER').and_return type_other_element }
    let(:type_other_element) { nil }

    context "when the contype element in the given data is empty" do
      let(:type_element) { double 'type element', text: '' }
      it "returns nil" do
        expect(pub.publication_type).to eq nil
      end
    end

    context "when the contype element in the given data contains 'journal article, academic journal'" do
      let(:type_element) { double 'type element', text: 'journal article, academic journal' }
      it "returns 'Academic Journal Article'" do
        expect(pub.publication_type).to eq 'Academic Journal Article'
      end
    end
    context "when the contype element in the given data contains 'Journal Article, Academic Journal'" do
      let(:type_element) { double 'type element', text: 'Journal Article, Academic Journal' }
      it "returns 'Academic Journal Article'" do
        expect(pub.publication_type).to eq 'Academic Journal Article'
      end
    end
    context "when the contype element in the given data contains '  journal article, academic journal  '" do
      let(:type_element) { double 'type element', text: '  journal article, academic journal  ' }
      it "returns 'Academic Journal Article'" do
        expect(pub.publication_type).to eq 'Academic Journal Article'
      end
    end

    context "when the contype element in the given data contains 'journal article, in-house journal'" do
      let(:type_element) { double 'type element', text: 'journal article, in-house journal' }
      it "returns 'In-house Journal Article'" do
        expect(pub.publication_type).to eq 'In-house Journal Article'
      end
    end
    context "when the contype element in the given data contains 'Journal Article, In-house Journal'" do
      let(:type_element) { double 'type element', text: 'Journal Article, In-house Journal' }
      it "returns 'In-house Journal Article'" do
        expect(pub.publication_type).to eq 'In-house Journal Article'
      end
    end
    context "when the contype element in the given data contains '  journal article, in-house journal  '" do
      let(:type_element) { double 'type element', text: '  journal article, in-house journal  ' }
      it "returns 'In-house Journal Article'" do
        expect(pub.publication_type).to eq 'In-house Journal Article'
      end
    end
    context "when the contype element in the given data contains 'journal article, in-house'" do
      let(:type_element) { double 'type element', text: 'journal article, in-house' }
      it "returns 'In-house Journal Article'" do
        expect(pub.publication_type).to eq 'In-house Journal Article'
      end
    end
    context "when the contype element in the given data contains 'Journal Article, In-house'" do
      let(:type_element) { double 'type element', text: 'Journal Article, In-house' }
      it "returns 'In-house Journal Article'" do
        expect(pub.publication_type).to eq 'In-house Journal Article'
      end
    end
    context "when the contype element in the given data contains '  journal article, in-house  '" do
      let(:type_element) { double 'type element', text: '  journal article, in-house  ' }
      it "returns 'In-house Journal Article'" do
        expect(pub.publication_type).to eq 'In-house Journal Article'
      end
    end

    context "when the contype element in the given data contains 'journal article, professional journal'" do
      let(:type_element) { double 'type element', text: 'journal article, professional journal' }
      it "returns 'Professional Journal Article'" do
        expect(pub.publication_type).to eq 'Professional Journal Article'
      end
    end
    context "when the contype element in the given data contains 'Journal Article, Professional Journal'" do
      let(:type_element) { double 'type element', text: 'Journal Article, Professional Journal' }
      it "returns 'Professional Journal Article'" do
        expect(pub.publication_type).to eq 'Professional Journal Article'
      end
    end
    context "when the contype element in the given data contains '  journal article, professional journal  '" do
      let(:type_element) { double 'type element', text: '  journal article, professional journal  ' }
      it "returns 'Professional Journal Article'" do
        expect(pub.publication_type).to eq 'Professional Journal Article'
      end
    end

    context "when the contype element in the given data contains 'journal article, public or trade journal'" do
      let(:type_element) { double 'type element', text: 'journal article, public or trade journal' }
      it "returns 'Trade Journal Article'" do
        expect(pub.publication_type).to eq 'Trade Journal Article'
      end
    end
    context "when the contype element in the given data contains 'Journal Article, Public or Trade Journal'" do
      let(:type_element) { double 'type element', text: 'Journal Article, Public or Trade Journal' }
      it "returns 'Trade Journal Article'" do
        expect(pub.publication_type).to eq 'Trade Journal Article'
      end
    end
    context "when the contype element in the given data contains '  journal article, public or trade journal  '" do
      let(:type_element) { double 'type element', text: '  journal article, public or trade journal  ' }
      it "returns 'Trade Journal Article'" do
        expect(pub.publication_type).to eq 'Trade Journal Article'
      end
    end
    context "when the contype element in the given data contains 'magazine or trade journal article'" do
      let(:type_element) { double 'type element', text: 'magazine or trade journal article' }
      it "returns 'Trade Journal Article'" do
        expect(pub.publication_type).to eq 'Trade Journal Article'
      end
    end
    context "when the contype element in the given data contains 'Magazine or Trade Journal Article'" do
      let(:type_element) { double 'type element', text: 'Magazine or Trade Journal Article' }
      it "returns 'Trade Journal Article'" do
        expect(pub.publication_type).to eq 'Trade Journal Article'
      end
    end
    context "when the contype element in the given data contains '  magazine or trade journal article  '" do
      let(:type_element) { double 'type element', text: '  magazine or trade journal article  ' }
      it "returns 'Trade Journal Article'" do
        expect(pub.publication_type).to eq 'Trade Journal Article'
      end
    end

    context "when the contype element in the given data contains 'journal article'" do
      let(:type_element) { double 'type element', text: 'journal article' }
      it "returns 'Journal Article'" do
        expect(pub.publication_type).to eq 'Journal Article'
      end
    end
    context "when the contype element in the given data contains 'Journal Article'" do
      let(:type_element) { double 'type element', text: 'Journal Article' }
      it "returns 'Journal Article'" do
        expect(pub.publication_type).to eq 'Journal Article'
      end
    end
    context "when the contype element in the given data contains '  journal article  '" do
      let(:type_element) { double 'type element', text: '  journal article  ' }
      it "returns 'Journal Article'" do
        expect(pub.publication_type).to eq 'Journal Article'
      end
    end

    context "when the contype element in the given data contains 'book' " do
      let(:type_element) { double 'type element', text: 'book' }
      it "returns nil" do
        expect(pub.publication_type).to eq nil
      end
    end


    context "when the contype element in the given data contains 'other'" do
      let(:type_element) { double 'type element', text: 'other' }
      context "when the contypeother element in the given data is empty" do
        let(:type_other_element) { double 'type other element', text: '' }
        it "returns nil" do
          expect(pub.publication_type).to eq nil
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
      context "when the contypeother element in the given data contains '  journal article, academic journal  '" do
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
      context "when the contypeother element in the given data contains '  journal article, in-house journal  '" do
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
      context "when the contypeother element in the given data contains '  journal article, in-house  '" do
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
      context "when the contypeother element in the given data contains '  journal article, professional journal  '" do
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
      context "when the contypeother element in the given data contains '  journal article, public or trade journal  '" do
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
      context "when the contypeother element in the given data contains '  magazine or trade journal article  '" do
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
      context "when the contypeother element in the given data contains '  journal article  '" do
        let(:type_other_element) { double 'type other element', text: '  journal article  ' }
        it "returns 'Journal Article'" do
          expect(pub.publication_type).to eq 'Journal Article'
        end
      end
  
      context "when the contypeother element in the given data contains 'book' " do
        let(:type_other_element) { double 'type other element', text: 'book' }
        it "returns nil" do
          expect(pub.publication_type).to eq nil
        end
      end
    end
    context "when the contype element in the given data contains 'OTHER'" do
      let(:type_element) { double 'type element', text: 'OTHER' }
      context "when the contypeother element in the given data is empty" do
        let(:type_other_element) { double 'type other element', text: '' }
        it "returns nil" do
          expect(pub.publication_type).to eq nil
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
      context "when the contypeother element in the given data contains '  journal article, academic journal  '" do
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
      context "when the contypeother element in the given data contains '  journal article, in-house journal  '" do
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
      context "when the contypeother element in the given data contains '  journal article, in-house  '" do
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
      context "when the contypeother element in the given data contains '  journal article, professional journal  '" do
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
      context "when the contypeother element in the given data contains '  journal article, public or trade journal  '" do
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
      context "when the contypeother element in the given data contains '  magazine or trade journal article  '" do
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
      context "when the contypeother element in the given data contains '  journal article  '" do
        let(:type_other_element) { double 'type other element', text: '  journal article  ' }
        it "returns 'Journal Article'" do
          expect(pub.publication_type).to eq 'Journal Article'
        end
      end
  
      context "when the contypeother element in the given data contains 'book' " do
        let(:type_other_element) { double 'type other element', text: 'book' }
        it "returns nil" do
          expect(pub.publication_type).to eq nil
        end
      end
    end
    context "when the contype element in the given data contains '  other  '" do
      let(:type_element) { double 'type element', text: '  other  ' }
      context "when the contypeother element in the given data is empty" do
        let(:type_other_element) { double 'type other element', text: '' }
        it "returns nil" do
          expect(pub.publication_type).to eq nil
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
      context "when the contypeother element in the given data contains '  journal article, academic journal  '" do
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
      context "when the contypeother element in the given data contains '  journal article, in-house journal  '" do
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
      context "when the contypeother element in the given data contains '  journal article, in-house  '" do
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
      context "when the contypeother element in the given data contains '  journal article, professional journal  '" do
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
      context "when the contypeother element in the given data contains '  journal article, public or trade journal  '" do
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
      context "when the contypeother element in the given data contains '  magazine or trade journal article  '" do
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
      context "when the contypeother element in the given data contains '  journal article  '" do
        let(:type_other_element) { double 'type other element', text: '  journal article  ' }
        it "returns 'Journal Article'" do
          expect(pub.publication_type).to eq 'Journal Article'
        end
      end
  
      context "when the contypeother element in the given data contains 'book' " do
        let(:type_other_element) { double 'type other element', text: 'book' }
        it "returns nil" do
          expect(pub.publication_type).to eq nil
        end
      end
    end
  end

  describe '#status' do
    before { allow(parsed_pub).to receive(:css).with('STATUS').and_return status_element }

    context "when the status element in the given data is empty" do
      let(:status_element) { double 'status element', text: '' }
      it "returns nil" do
        expect(pub.status).to be_nil
      end
    end

    context "when the status element in the given data contains text" do
      let(:status_element) { double 'status element', text: "\n     Status  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(pub.status).to eq 'Status'
      end
    end
  end

  describe '#importable?' do
    before { allow(parsed_pub).to receive(:css).with('STATUS').and_return status_element }
    before { allow(parsed_pub).to receive(:css).with('CONTYPE').and_return type_element }
    before { allow(parsed_pub).to receive(:css).with('CONTYPEOTHER').and_return type_other_element }
    let(:type_other_element) { nil }

    context "when the status element in the given data does not contain 'Published'" do
      let(:status_element) { double 'status element', text: 'Other Status' }
      context "when the contype element in the given data is a known type that case-insensivitly matches 'journal article'" do
        let(:type_element) { double 'type element', text: 'Magazine or Trade Journal Article' }
        it "returns false" do
          expect(pub.importable?).to eq false
        end
      end
      context "when the contype element in the given data does not case-insensivitly match 'journal article'" do
        let(:type_element) { double 'type element', text: 'Some Kind of Thing' }
        it "returns false" do
          expect(pub.importable?).to eq false
        end
      end
      context "when the contype element in the given data contains 'other'" do
        let(:type_element) { double 'type element', text: 'other' }
        context "when the contypeother element in the given data is a known type that case-insensivitly matches 'journal article'" do
          let(:type_other_element) { double 'type element', text: 'Magazine or Trade Journal Article' }
          it "returns false" do
            expect(pub.importable?).to eq false
          end
        end
        context "when the contypeother element in the given data does not case-insensivitly match 'journal article'" do
          let(:type_other_element) { double 'type element', text: 'Some Kind of Thing' }
          it "returns false" do
            expect(pub.importable?).to eq false
          end
        end
      end
    end

    context "when the status element in the given data contains 'Published" do
      let(:status_element) { double 'status element', text: "Published" }
      context "when the contype element in the given data is a known type that case-insensivitly matches 'journal article'" do
        let(:type_element) { double 'type element', text: 'Magazine or Trade Journal Article' }
        it "returns true" do
          expect(pub.importable?).to eq true
        end
      end
      context "when the contype element in the given data does not case-insensivitly match 'journal article'" do
        let(:type_element) { double 'type element', text: 'Some Kind of Thing' }
        it "returns false" do
          expect(pub.importable?).to eq false
        end
      end
      context "when the contype element in the given data contains 'other'" do
        let(:type_element) { double 'type element', text: 'other' }
        context "when the contypeother element in the given data is a known type that case-insensivitly matches 'journal article'" do
          let(:type_other_element) { double 'type element', text: 'Magazine or Trade Journal Article' }
          it "returns true" do
            expect(pub.importable?).to eq true
          end
        end
        context "when the contypeother element in the given data does not case-insensivitly match 'journal article'" do
          let(:type_other_element) { double 'type element', text: 'Some Kind of Thing' }
          it "returns false" do
            expect(pub.importable?).to eq false
          end
        end
      end
    end
  end

  describe '#activity_insight_id' do
    let(:id_attr) { double 'id attribute', value: '9'}
    before { allow(parsed_pub).to receive(:attribute).with('id').and_return(id_attr) }

    it "returns the id attribute from the given element" do
      expect(pub.activity_insight_id).to eq '9'
    end
  end

  describe '#title' do
    before { allow(parsed_pub).to receive(:css).with('TITLE').and_return title_element }

    context "when the title element in the given data is empty" do
      let(:title_element) { double 'title element', text: '' }
      it "returns nil" do
        expect(pub.title).to be_nil
      end
    end

    context "when the title element in the given data contains text" do
      let(:title_element) { double 'title element', text: "\n     Title  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(pub.title).to eq 'Title'
      end
    end
  end
end
