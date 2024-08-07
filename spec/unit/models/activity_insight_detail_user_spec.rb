# frozen_string_literal: true

require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/importers/activity_insight_importer'

describe ActivityInsightDetailUser do
  let(:user_data) { double 'parsed user data' }
  let(:parsed_user) { double 'parsed user' }
  let(:contact_info) { double 'parsed contact info' }
  let(:user) { described_class.new(parsed_user) }

  before do
    allow(parsed_user).to receive(:css).with('Data Record').and_return(user_data)
    allow(user_data).to receive(:css).with('PCI').and_return(contact_info)
  end

  describe '#webaccess_id' do
    let(:username_attr) { double 'username attribute', value: 'ABC123' }

    before { allow(user_data).to receive(:attribute).with('username').and_return(username_attr) }

    it 'returns the username attribute from the given data in all lower case' do
      expect(user.webaccess_id).to eq 'abc123'
    end
  end

  describe '#activity_insight_id' do
    let(:user_id_attr) { double 'user ID attribute', value: '123456' }

    before { allow(user_data).to receive(:attribute).with('userId').and_return(user_id_attr) }

    it 'returns the username attribute from the given data' do
      expect(user.activity_insight_id).to eq '123456'
    end
  end

  describe '#alt_name' do
    before { allow(contact_info).to receive(:css).with('ALT_NAME').and_return(an_element) }

    context 'when the Alt Name element in the given data is empty' do
      let(:an_element) { double 'alt name element', text: '' }

      it 'returns nil' do
        expect(user.alt_name).to be_nil
      end
    end

    context 'when the Alt Name element in the given data contains text' do
      let(:an_element) { double 'alt name element', text: "\n     Alt  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(user.alt_name).to eq 'Alt'
      end
    end
  end

  describe '#building' do
    before { allow(contact_info).to receive(:css).with('BUILDING').and_return(building_element) }

    context 'when the Building element in the given data is empty' do
      let(:building_element) { double 'building element', text: '' }

      it 'returns nil' do
        expect(user.building).to be_nil
      end
    end

    context 'when the Building element in the given data contains text' do
      let(:building_element) { double 'building element', text: "\n     Building  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(user.building).to eq 'Building'
      end
    end
  end

  describe '#room_number' do
    before { allow(contact_info).to receive(:css).with('ROOMNUM').and_return(room_number_element) }

    context 'when the Room Number element in the given data is empty' do
      let(:room_number_element) { double 'room element', text: '' }

      it 'returns nil' do
        expect(user.room_number).to be_nil
      end
    end

    context 'when the Room Number element in the given data contains text' do
      let(:room_number_element) { double 'room element', text: "\n     Room  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(user.room_number).to eq 'Room'
      end
    end
  end

  describe '#office_phone_1' do
    before { allow(contact_info).to receive(:css).with('OPHONE1').and_return(office_phone_1_element) }

    context 'when the Office Phone 1 element in the given data is empty' do
      let(:office_phone_1_element) { double 'office phone 1 element', text: '' }

      it 'returns nil' do
        expect(user.office_phone_1).to be_nil
      end
    end

    context 'when the Office Phone 1 element in the given data contains text' do
      let(:office_phone_1_element) { double 'office phone 1 element', text: "\n     Phone 1  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(user.office_phone_1).to eq 'Phone 1'
      end
    end
  end

  describe '#office_phone_2' do
    before { allow(contact_info).to receive(:css).with('OPHONE2').and_return(office_phone_2_element) }

    context 'when the Office Phone 2 element in the given data is empty' do
      let(:office_phone_2_element) { double 'office phone 2 element', text: '' }

      it 'returns nil' do
        expect(user.office_phone_2).to be_nil
      end
    end

    context 'when the Office Phone 2 element in the given data contains text' do
      let(:office_phone_2_element) { double 'office phone 2 element', text: "\n     Phone 2  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(user.office_phone_2).to eq 'Phone 2'
      end
    end
  end

  describe '#office_phone_3' do
    before { allow(contact_info).to receive(:css).with('OPHONE3').and_return(office_phone_3_element) }

    context 'when the Office Phone 3 element in the given data is empty' do
      let(:office_phone_3_element) { double 'office phone 3 element', text: '' }

      it 'returns nil' do
        expect(user.office_phone_3).to be_nil
      end
    end

    context 'when the Office Phone 3 element in the given data contains text' do
      let(:office_phone_3_element) { double 'office phone 3 element', text: "\n     Phone 3  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(user.office_phone_3).to eq 'Phone 3'
      end
    end
  end

  describe '#fax_1' do
    before { allow(contact_info).to receive(:css).with('FAX1').and_return(fax_1_element) }

    context 'when the Fax 1 element in the given data is empty' do
      let(:fax_1_element) { double 'fax 1 element', text: '' }

      it 'returns nil' do
        expect(user.fax_1).to be_nil
      end
    end

    context 'when the Fax 1 element in the given data contains text' do
      let(:fax_1_element) { double 'fax 1 element', text: "\n     Fax 1  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(user.fax_1).to eq 'Fax 1'
      end
    end
  end

  describe '#fax_2' do
    before { allow(contact_info).to receive(:css).with('FAX2').and_return(fax_2_element) }

    context 'when the Fax 2 element in the given data is empty' do
      let(:fax_2_element) { double 'fax 2 element', text: '' }

      it 'returns nil' do
        expect(user.fax_2).to be_nil
      end
    end

    context 'when the Fax 2 element in the given data contains text' do
      let(:fax_2_element) { double 'fax 2 element', text: "\n     Fax 2  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(user.fax_2).to eq 'Fax 2'
      end
    end
  end

  describe '#fax_3' do
    before { allow(contact_info).to receive(:css).with('FAX3').and_return(fax_3_element) }

    context 'when the Fax 3 element in the given data is empty' do
      let(:fax_3_element) { double 'fax 3 element', text: '' }

      it 'returns nil' do
        expect(user.fax_3).to be_nil
      end
    end

    context 'when the Fax 3 element in the given data contains text' do
      let(:fax_3_element) { double 'fax 3 element', text: "\n     Fax 3  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(user.fax_3).to eq 'Fax 3'
      end
    end
  end

  describe '#website' do
    before { allow(contact_info).to receive(:css).with('WEBSITE').and_return(website_element) }

    context 'when the Website element in the given data is empty' do
      let(:website_element) { double 'website element', text: '' }

      it 'returns nil' do
        expect(user.website).to be_nil
      end
    end

    context 'when the Website element in the given data contains text' do
      let(:website_element) { double 'website element', text: "\n     Website  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(user.website).to eq 'Website'
      end
    end
  end

  describe '#bio' do
    before { allow(user_data).to receive(:css).with('BIO').and_return bio_element }

    context 'when the Bio element in the given data is empty' do
      let(:bio_element) { double 'bio element', text: '' }

      it 'returns nil' do
        expect(user.bio).to be_nil
      end
    end

    context 'when the Bio element in the given data contains text' do
      let(:bio_element) { double 'bio element', text: "\n     Bio  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(user.bio).to eq 'Bio'
      end
    end
  end

  describe '#teaching_interests' do
    before { allow(user_data).to receive(:css).with('TEACHING_INTERESTS').and_return teaching_interests_element }

    context 'when the Teaching Interests element in the given data is empty' do
      let(:teaching_interests_element) { double 'teaching interests element', text: '' }

      it 'returns nil' do
        expect(user.teaching_interests).to be_nil
      end
    end

    context 'when the Teaching Interests element in the given data contains text' do
      let(:teaching_interests_element) { double 'teaching interests element', text: "\n     Teaching Interests  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(user.teaching_interests).to eq 'Teaching Interests'
      end
    end
  end

  describe '#research_interests' do
    before { allow(user_data).to receive(:css).with('RESEARCH_INTERESTS').and_return research_interests_element }

    context 'when the Research Interests element in the given data is empty' do
      let(:research_interests_element) { double 'research interests element', text: '' }

      it 'returns nil' do
        expect(user.research_interests).to be_nil
      end
    end

    context 'when the Research Interests element in the given data contains text' do
      let(:research_interests_element) { double 'research interests element', text: "\n     Research Interests  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(user.research_interests).to eq 'Research Interests'
      end
    end
  end

  describe '#education_history_items' do
    let(:element1) { double 'XML element 1' }
    let(:element2) { double 'XML element 2' }
    let(:item1) { double 'education history item 1' }
    let(:item2) { double 'education history item 2' }

    before do
      allow(user_data).to receive(:css).with('EDUCATION').and_return([element1, element2])
      allow(ActivityInsightEducationHistoryItem).to receive(:new).with(element1).and_return(item1)
      allow(ActivityInsightEducationHistoryItem).to receive(:new).with(element2).and_return(item2)
    end

    it 'returns an array of education history items from the given data' do
      expect(user.education_history_items).to eq [item1, item2]
    end
  end

  describe '#presentations' do
    let(:element1) { double 'XML element 1' }
    let(:element2) { double 'XML element 2' }
    let(:pres1) { double 'presentation 1' }
    let(:pres2) { double 'presentation 2' }

    before do
      allow(user_data).to receive(:css).with('PRESENT').and_return([element1, element2])
      allow(ActivityInsightPresentation).to receive(:new).with(element1).and_return(pres1)
      allow(ActivityInsightPresentation).to receive(:new).with(element2).and_return(pres2)
    end

    it 'returns an array of presentations from the given data' do
      expect(user.presentations).to eq [pres1, pres2]
    end
  end

  describe '#performances' do
    let(:element1) { double 'XML element 1' }
    let(:element2) { double 'XML element 2' }
    let(:perf1) { double 'performance 1' }
    let(:perf2) { double 'performance 2' }

    before do
      allow(user_data).to receive(:css).with('PERFORM_EXHIBIT').and_return([element1, element2])
      allow(ActivityInsightPerformance).to receive(:new).with(element1).and_return(perf1)
      allow(ActivityInsightPerformance).to receive(:new).with(element2).and_return(perf2)
    end

    it 'returns an array of performances from the given data' do
      expect(user.performances).to eq [perf1, perf2]
    end
  end

  describe '#publications' do
    let(:element1) { double 'XML element 1' }
    let(:element2) { double 'XML element 2' }
    let(:pub1) { double 'publication 1' }
    let(:pub2) { double 'publication 2' }

    before do
      allow(user_data).to receive(:css).with('INTELLCONT').and_return([element1, element2])
      allow(ActivityInsightPublication).to receive(:new).with(element1, user).and_return(pub1)
      allow(ActivityInsightPublication).to receive(:new).with(element2, user).and_return(pub2)
    end

    it 'returns an array of publications from the given data' do
      expect(user.publications).to eq [pub1, pub2]
    end
  end
end
