require 'component/component_spec_helper'

describe NSFGrant do
  let(:parsed_grant) { double 'parsed grant xml' }
  let(:grant) { NSFGrant.new(parsed_grant) }

  describe '#importable?' do
    context "when the given data lists no institutions" do
      before { allow(parsed_grant).to receive(:css).with('Institution').and_return [] }

      xit

    end
    context "when the given data lists an institution that does not match Penn State" do
      let(:inst) { double 'institution' }
      let(:name_element) { double 'name element', text: "   \n Other University \n   " }
      before do
        allow(parsed_grant).to receive(:css).with('Institution').and_return [inst]
        allow(inst).to receive(:css).with('Name').and_return name_element
      end

      xit

    end
    context "when the given data lists an institution that matches Penn State" do
      let(:inst1) { double 'institution 1' }
      let(:inst2) { double 'institution 2' }
      let(:name_element1) { double 'name element 1', text: "   \n Other University \n   " }
      let(:name_element2) { double 'name element 2', text: "   \n Pennsylvania State Univ University Park \n   " }
      before do
        allow(parsed_grant).to receive(:css).with('Institution').and_return [inst1, inst2]
        allow(inst1).to receive(:css).with('Name').and_return name_element1
        allow(inst2).to receive(:css).with('Name').and_return name_element2
      end

      xit
      
    end
  end

  describe '#title' do
    before { allow(parsed_grant).to receive(:css).with('AwardTitle').and_return title_element }

    context "when the Title element in the given data is empty" do
      let(:title_element) { double 'title element', text: '' }
      it "returns nil" do
        expect(grant.title).to be_nil
      end
    end

    context "when the Title element in the given data contains text" do
      let(:title_element) { double 'title element', text: "\n     Title  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(grant.title).to eq 'Title'
      end
    end
  end
end
