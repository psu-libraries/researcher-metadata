require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/importers/activity_insight_importer'

describe ActivityInsightPresentation do
  let(:parsed_pres) { double 'parsed item xml' }
  let(:pres) { ActivityInsightPresentation.new(parsed_pres) }

  describe '#activity_insight_id' do
    let(:id_attr) { double 'id attribute', value: '8'}
    before { allow(parsed_pres).to receive(:attribute).with('id').and_return(id_attr) }

    it "returns the id attribute from the given element" do
      expect(pres.activity_insight_id).to eq '8'
    end
  end

  describe '#title' do
    before { allow(parsed_pres).to receive(:css).with('TITLE').and_return title_element }

    context "when the Title element in the given data is empty" do
      let(:title_element) { double 'title element', text: '' }
      it "returns nil" do
        expect(pres.title).to be_nil
      end
    end

    context "when the Title element in the given data contains text" do
      let(:title_element) { double 'title element', text: "\n     Title  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(pres.title).to eq 'Title'
      end
    end
  end
end
