require 'component/component_spec_helper'

describe NSFGrant do
  let(:parsed_grant) { double 'parsed grant xml' }
  let(:grant) { NSFGrant.new(parsed_grant) }

  describe '#importable?' do
    context 'when the given data lists no institutions' do
      before { allow(parsed_grant).to receive(:css).with('Institution').and_return [] }

      it 'returns false' do
        expect(grant.importable?).to eq false
      end
    end

    context 'when the given data lists an institution that does not match Penn State' do
      let(:inst) { double 'institution' }
      let(:name_element) { double 'name element', text: "   \n Other University \n   " }

      before do
        allow(parsed_grant).to receive(:css).with('Institution').and_return [inst]
        allow(inst).to receive(:css).with('Name').and_return name_element
      end

      it 'returns false' do
        expect(grant.importable?).to eq false
      end
    end

    context 'when the given data lists an institution that matches Penn State' do
      let(:inst1) { double 'institution 1' }
      let(:inst2) { double 'institution 2' }
      let(:name_element1) { double 'name element 1', text: "   \n Other University \n   " }
      let(:name_element2) { double 'name element 2', text: "   \n Pennsylvania State Univ University Park \n   " }

      before do
        allow(parsed_grant).to receive(:css).with('Institution').and_return [inst1, inst2]
        allow(inst1).to receive(:css).with('Name').and_return name_element1
        allow(inst2).to receive(:css).with('Name').and_return name_element2
      end

      it 'returns true' do
        expect(grant.importable?).to eq true
      end
    end
  end

  describe '#title' do
    before { allow(parsed_grant).to receive(:css).with('AwardTitle').and_return title_element }

    context 'when the Title element in the given data is empty' do
      let(:title_element) { double 'title element', text: '' }

      it 'returns nil' do
        expect(grant.title).to be_nil
      end
    end

    context 'when the Title element in the given data contains text' do
      let(:title_element) { double 'title element', text: "\n     Title  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(grant.title).to eq 'Title'
      end
    end
  end

  describe '#start_date' do
    before { allow(parsed_grant).to receive(:css).with('AwardEffectiveDate').and_return start_date_element }

    context 'when the start date element in the given data is empty' do
      let(:start_date_element) { double 'start date element', text: '' }

      it 'returns nil' do
        expect(grant.start_date).to be_nil
      end
    end

    context 'when the start date element in the given data contains text' do
      let(:start_date_element) { double 'start date element', text: "\n   07/15/2009    \n   " }

      it 'returns the start date of the grant' do
        expect(grant.start_date).to eq Date.new(2009, 7, 15)
      end
    end
  end

  describe '#end_date' do
    before { allow(parsed_grant).to receive(:css).with('AwardExpirationDate').and_return end_date_element }

    context 'when the end date element in the given data is empty' do
      let(:end_date_element) { double 'end date element', text: '' }

      it 'returns nil' do
        expect(grant.end_date).to be_nil
      end
    end

    context 'when the end date element in the given data contains text' do
      let(:end_date_element) { double 'end date element', text: "\n   07/14/2012    \n   " }

      it 'returns the end date of the grant' do
        expect(grant.end_date).to eq Date.new(2012, 7, 14)
      end
    end
  end

  describe '#abstract' do
    before { allow(parsed_grant).to receive(:css).with('AbstractNarration').and_return abstract_element }

    context 'when the abstract element in the given data is empty' do
      let(:abstract_element) { double 'abstract element', text: '' }

      it 'returns nil' do
        expect(grant.abstract).to be_nil
      end
    end

    context 'when the abstract element in the given data contains text' do
      let(:abstract_element) { double 'abstract element', text: "\n     This is the abstract.  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(grant.abstract).to eq 'This is the abstract.'
      end
    end
  end

  describe '#amount_in_dollars' do
    before { allow(parsed_grant).to receive(:css).with('AwardAmount').and_return amount_element }

    context 'when the amount element in the given data is empty' do
      let(:amount_element) { double 'amount element', text: '' }

      it 'returns nil' do
        expect(grant.amount_in_dollars).to be_nil
      end
    end

    context 'when the amount element in the given data contains text' do
      let(:amount_element) { double 'amount element', text: "\n     20000  \n   " }

      it 'returns the amount of the grant in dollars' do
        expect(grant.amount_in_dollars).to eq 20000
      end
    end
  end

  describe '#identifier' do
    before { allow(parsed_grant).to receive(:css).with('AwardID').and_return id_element }

    context 'when the ID element in the given data is empty' do
      let(:id_element) { double 'id element', text: '' }

      it 'returns nil' do
        expect(grant.identifier).to be_nil
      end
    end

    context 'when the ID element in the given data contains text' do
      let(:id_element) { double 'id element', text: "\n     1234567  \n   " }

      it 'returns the text with surrounding whitespace removed' do
        expect(grant.identifier).to eq '1234567'
      end
    end
  end

  describe '#agency_name' do
    it "returns 'National Science Foundation'" do
      expect(grant.agency_name).to eq 'National Science Foundation'
    end
  end

  describe '#investigators' do
    let(:investigator_element1) { double 'investigator element 1' }
    let(:investigator_element2) { double 'investigator element 2' }
    let(:investigator1) { double 'investigator 1' }
    let(:investigator2) { double 'investigator 2' }

    before do
      allow(NSFInvestigator).to receive(:new).with(investigator_element1).and_return(investigator1)
      allow(NSFInvestigator).to receive(:new).with(investigator_element2).and_return(investigator2)
      allow(parsed_grant).to receive(:css).with('Investigator').and_return([investigator_element1, investigator_element2])
    end

    it 'returns an array of the investigators associated with the grant' do
      expect(grant.investigators).to eq [investigator1, investigator2]
    end
  end
end
