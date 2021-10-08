# frozen_string_literal: true

require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/importers/activity_insight_importer'

describe ActivityInsightPerformance do
  let(:parsed_perf) { double 'parsed item xml' }
  let(:perf) { described_class.new(parsed_perf) }

  describe '#activity_insight_id' do
    let(:id_attr) { double 'id attribute', value: '8' }

    before { allow(parsed_perf).to receive(:attribute).with('id').and_return(id_attr) }

    it 'returns the id attribute from the given element' do
      expect(perf.activity_insight_id).to eq '8'
    end
  end

  describe '#title' do
    before { allow(parsed_perf).to receive(:css).with('TITLE').and_return title_element }

    context 'when the Title element in the given data is empty' do
      let(:title_element) { double 'title element', text: '' }

      it 'returns nil' do
        expect(perf.title).to be_nil
      end
    end

    context 'when the Title element in the given data contains text' do
      let(:title_element) { double 'title element', text: "\n     Title  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(perf.title).to eq 'Title'
      end
    end
  end

  describe '#type' do
    before do
      allow(parsed_perf).to receive(:css).with('TYPE').and_return type_element
      allow(parsed_perf).to receive(:css).with('TYPE_OTHER').and_return type_other_element
    end

    context 'when the Type element in the given data is empty' do
      let(:type_element) { double 'type element', text: '' }

      context 'when the Type Other element in the given data is empty' do
        let(:type_other_element) { double 'type other element', text: '' }

        it 'returns nil' do
          expect(perf.type).to be_nil
        end
      end

      context 'when the Type Other element in the given data contains text' do
        let(:type_other_element) { double 'type other element', text: "\n     Other Type  \n   " }

        it 'returns the Type Other text with surrounding whitespace removed' do
          expect(perf.type).to eq 'Other Type'
        end
      end
    end

    context 'when the Type element in the given data contains text' do
      let(:type_element) { double 'type element', text: "\n     Type  \n   " }

      context 'when the Type Other element in the given data is empty' do
        let(:type_other_element) { double 'type other element', text: '' }

        it 'returns nil' do
          expect(perf.type).to eq 'Type'
        end
      end

      context 'when the Type Other element in the given data contains text' do
        let(:type_other_element) { double 'type other element', text: "\n     Other Type  \n   " }

        it 'returns the Type text with surrounding whitespace removed' do
          expect(perf.type).to eq 'Type'
        end
      end
    end

    context "when the text in the Type element in the given data is 'Other'" do
      let(:type_element) { double 'type element', text: 'Other' }

      context 'when the Type Other element in the given data is empty' do
        let(:type_other_element) { double 'type other element', text: '' }

        it 'returns nil' do
          expect(perf.type).to be_nil
        end
      end

      context 'when the Type Other element in the given data contains text' do
        let(:type_other_element) { double 'type other element', text: "\n     Other Type  \n   " }

        it 'returns the Type Other text with surrounding whitespace removed' do
          expect(perf.type).to eq 'Other Type'
        end
      end
    end
  end

  describe '#sponsor' do
    before { allow(parsed_perf).to receive(:css).with('SPONSOR').and_return sponsor_element }

    context 'when the Sponsor element in the given data is empty' do
      let(:sponsor_element) { double 'sponsor element', text: '' }

      it 'returns nil' do
        expect(perf.sponsor).to be_nil
      end
    end

    context 'when the Sponsor element in the given data contains text' do
      let(:sponsor_element) { double 'sponsor element', text: "\n     Sponsor  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(perf.sponsor).to eq 'Sponsor'
      end
    end
  end

  describe '#description' do
    before { allow(parsed_perf).to receive(:css).with('DESC').and_return description_element }

    context 'when the Description element in the given data is empty' do
      let(:description_element) { double 'description element', text: '' }

      it 'returns nil' do
        expect(perf.description).to be_nil
      end
    end

    context 'when the Description element in the given data contains text' do
      let(:description_element) { double 'description element', text: "\n     Description  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(perf.description).to eq 'Description'
      end
    end
  end

  describe '#name' do
    before { allow(parsed_perf).to receive(:css).with('NAME').and_return name_element }

    context 'when the Name element in the given data is empty' do
      let(:name_element) { double 'name element', text: '' }

      it 'returns nil' do
        expect(perf.name).to be_nil
      end
    end

    context 'when the Name element in the given data contains text' do
      let(:name_element) { double 'name element', text: "\n     Name  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(perf.name).to eq 'Name'
      end
    end
  end

  describe '#location' do
    before { allow(parsed_perf).to receive(:css).with('LOCATION').and_return location_element }

    context 'when the Location element in the given data is empty' do
      let(:location_element) { double 'location element', text: '' }

      it 'returns nil' do
        expect(perf.location).to be_nil
      end
    end

    context 'when the Location element in the given data contains text' do
      let(:location_element) { double 'location element', text: "\n     Location  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(perf.location).to eq 'Location'
      end
    end
  end

  describe '#delivery_type' do
    before { allow(parsed_perf).to receive(:css).with('DELIVERY_TYPE').and_return delivery_type_element }

    context 'when the Delivery Type element in the given data is empty' do
      let(:delivery_type_element) { double 'delivery type element', text: '' }

      it 'returns nil' do
        expect(perf.delivery_type).to be_nil
      end
    end

    context 'when the Delivery Type element in the given data contains text' do
      let(:delivery_type_element) { double 'delivery type element', text: "\n     Delivery Type  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(perf.delivery_type).to eq 'Delivery Type'
      end
    end
  end

  describe '#scope' do
    before { allow(parsed_perf).to receive(:css).with('SCOPE').and_return scope_element }

    context 'when the Scope element in the given data is empty' do
      let(:scope_element) { double 'scope element', text: '' }

      it 'returns nil' do
        expect(perf.scope).to be_nil
      end
    end

    context 'when the Scope element in the given data contains text' do
      let(:scope_element) { double 'scope element', text: "\n     Scope  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(perf.scope).to eq 'Scope'
      end
    end
  end

  describe '#start_on' do
    before { allow(parsed_perf).to receive(:css).with('START_START').and_return start_element }

    context 'when the Start Start element in the given data is empty' do
      let(:start_element) { double 'start start element', text: '' }

      it 'returns nil' do
        expect(perf.start_on).to be_nil
      end
    end

    context 'when the Start Start element in the given data contains text' do
      let(:start_element) { double 'start start element', text: "\n     Start  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(perf.start_on).to eq 'Start'
      end
    end
  end

  describe '#end_on' do
    before { allow(parsed_perf).to receive(:css).with('END_START').and_return end_element }

    context 'when the End Start element in the given data is empty' do
      let(:end_element) { double 'end start element', text: '' }

      it 'returns nil' do
        expect(perf.end_on).to be_nil
      end
    end

    context 'when the End Start element in the given data contains text' do
      let(:end_element) { double 'end start element', text: "\n     End  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(perf.end_on).to eq 'End'
      end
    end
  end

  describe '#contributors' do
    let(:element1) { double 'XML element 1' }
    let(:element2) { double 'XML element 2' }
    let(:contributor1) { double 'contributor 1' }
    let(:contributor2) { double 'contributor 2' }

    before do
      allow(parsed_perf).to receive(:css).with('PERFORM_EXHIBIT_CONTRIBUTERS').and_return([element1, element2])
      allow(ActivityInsightPerformanceContributor).to receive(:new).with(element1).and_return(contributor1)
      allow(ActivityInsightPerformanceContributor).to receive(:new).with(element2).and_return(contributor2)
    end

    it 'returns an array of contributors from the given data' do
      expect(perf.contributors).to eq [contributor1, contributor2]
    end
  end
end
