require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/importers/activity_insight_importer'

describe ActivityInsightPresentationContributor do
  let(:parsed_contributor) { double 'parsed contributor xml' }
  let(:contributor) { ActivityInsightPresentationContributor.new(parsed_contributor) }

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

  describe '#role' do
    before do
      allow(parsed_contributor).to receive(:css).with('ROLE').and_return role_element
      allow(parsed_contributor).to receive(:css).with('ROLE_OTHER').and_return role_other_element
    end

    context 'when the Role element in the given data is empty' do
      let(:role_element) { double 'role element', text: '' }

      context 'when the Role Other element in the given data is empty' do
        let(:role_other_element) { double 'role other element', text: '' }

        it 'returns nil' do
          expect(contributor.role).to be_nil
        end
      end

      context 'when the Role Other element in the given data contains text' do
        let(:role_other_element) { double 'role other element', text: "\n     Other Role  \n   " }

        it 'returns the Role Other text with surrounding whitespace removed' do
          expect(contributor.role).to eq 'Other Role'
        end
      end
    end

    context 'when the Role element in the given data contains text' do
      let(:role_element) { double 'role element', text: "\n     Role  \n   " }

      context 'when the Role Other element in the given data is empty' do
        let(:role_other_element) { double 'role other element', text: '' }

        it 'returns nil' do
          expect(contributor.role).to eq 'Role'
        end
      end

      context 'when the Role Other element in the given data contains text' do
        let(:role_other_element) { double 'role other element', text: "\n     Other Role  \n   " }

        it 'returns the Role text with surrounding whitespace removed' do
          expect(contributor.role).to eq 'Role'
        end
      end
    end

    context "when the text in the Role element in the given data is 'Other'" do
      let(:role_element) { double 'role element', text: 'Other' }

      context 'when the Role Other element in the given data is empty' do
        let(:role_other_element) { double 'role other element', text: '' }

        it 'returns nil' do
          expect(contributor.role).to be_nil
        end
      end

      context 'when the Role Other element in the given data contains text' do
        let(:role_other_element) { double 'role other element', text: "\n     Other Role  \n   " }

        it 'returns the Role Other text with surrounding whitespace removed' do
          expect(contributor.role).to eq 'Other Role'
        end
      end
    end
  end
end
