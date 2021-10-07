require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/importers/activity_insight_importer'

describe ActivityInsightPerformanceContributor do
  let(:parsed_contributor) { double 'parsed contributor xml' }
  let(:contributor) { ActivityInsightPerformanceContributor.new(parsed_contributor) }

  describe '#activity_insight_id' do
    let(:id_attr) { double 'id attribute', value: '8' }

    before { allow(parsed_contributor).to receive(:attribute).with('id').and_return(id_attr) }

    it 'returns the id attribute from the given element' do
      expect(contributor.activity_insight_id).to eq '8'
    end
  end

  describe '#activity_insight_user_id' do
    before { allow(parsed_contributor).to receive(:css).with('FACULTY_NAME').and_return faculty_name_element }

    context 'when the Faculty Name element in the given data is empty' do
      let(:faculty_name_element) { double 'faculty name element', text: '' }

      it 'returns nil' do
        expect(contributor.activity_insight_user_id).to be_nil
      end
    end

    context 'when the Faculty Name element in the given data contains text' do
      let(:faculty_name_element) { double 'faculty name element', text: "\n     123456  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(contributor.activity_insight_user_id).to eq '123456'
      end
    end
  end

  describe '#contribution' do
    before { allow(parsed_contributor).to receive(:css).with('CONTRIBUTION').and_return contribution_element }

    context 'when the Contribution element in the given data is empty' do
      let(:contribution_element) { double 'contribution element', text: '' }

      it 'returns nil' do
        expect(contributor.contribution).to be_nil
      end
    end

    context 'when the Contribution element in the given data contains text' do
      let(:contribution_element) { double 'contribution element', text: "\n     The Contribution  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(contributor.contribution).to eq 'The Contribution'
      end
    end
  end
end
