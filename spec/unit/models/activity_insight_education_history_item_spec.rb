require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/importers/activity_insight_importer'

describe ActivityInsightEducationHistoryItem do
  let(:parsed_item) { double 'parsed item xml' }
  let(:item) { ActivityInsightEducationHistoryItem.new(parsed_item) }

  describe '#activity_insight_id' do
    let(:id_attr) { double 'id attribute', value: '8'}
    before { allow(parsed_item).to receive(:attribute).with('id').and_return(id_attr) }

    it "returns the id attribute from the given element" do
      expect(item.activity_insight_id).to eq '8'
    end
  end

  describe '#degree' do
    before { allow(parsed_item).to receive(:css).with('DEG').and_return(degree_element) }

    context "when the Degree element in the given data is empty" do
      let(:degree_element) { double 'degree element', text: '' }
      it "returns nil" do
        expect(item.degree).to be_nil
      end
    end

    context "when the Degree element in the given data contains text" do
      let(:degree_element) { double 'degree element', text: "\n     Degree  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(item.degree).to eq 'Degree'
      end
    end
  end
end
