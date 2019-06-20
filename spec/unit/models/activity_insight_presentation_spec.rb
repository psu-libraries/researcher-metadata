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

  describe '#name' do
    before { allow(parsed_pres).to receive(:css).with('NAME').and_return name_element }

    context "when the Name element in the given data is empty" do
      let(:name_element) { double 'name element', text: '' }
      it "returns nil" do
        expect(pres.name).to be_nil
      end
    end

    context "when the Name element in the given data contains text" do
      let(:name_element) { double 'name element', text: "\n     Name  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(pres.name).to eq 'Name'
      end
    end
  end

  describe '#organization' do
    before { allow(parsed_pres).to receive(:>).with('ORG').and_return organization_element }

    context "when the Organization element in the given data is empty" do
      let(:organization_element) { double 'organization element', text: '' }
      it "returns nil" do
        expect(pres.organization).to be_nil
      end
    end

    context "when the Organization element in the given data contains text" do
      let(:organization_element) { double 'organization element', text: "\n     Organization  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(pres.organization).to eq 'Organization'
      end
    end
  end

  describe '#location' do
    before { allow(parsed_pres).to receive(:css).with('LOCATION').and_return location_element }

    context "when the Location element in the given data is empty" do
      let(:location_element) { double 'location element', text: '' }
      it "returns nil" do
        expect(pres.location).to be_nil
      end
    end

    context "when the Location element in the given data contains text" do
      let(:location_element) { double 'location element', text: "\n     Location  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(pres.location).to eq 'Location'
      end
    end
  end

  describe '#type' do
    before do
      allow(parsed_pres).to receive(:css).with('TYPE').and_return type_element
      allow(parsed_pres).to receive(:css).with('TYPE_OTHER').and_return type_other_element
    end

    context "when the Type element in the given data is empty" do
      let(:type_element) { double 'type element', text: '' }

      context "when the Type Other element in the given data is empty" do
        let(:type_other_element) { double 'type other element', text: '' }

        it "returns nil" do
          expect(pres.type).to be_nil
        end
      end

      context "when the Type Other element in the given data contains text" do
        let(:type_other_element) { double 'type other element', text: "\n     Other Type  \n   " }

        it "returns the Type Other text with surrounding whitespace removed" do
          expect(pres.type).to eq 'Other Type'
        end
      end
    end

    context "when the Type element in the given data contains text" do
      let(:type_element) { double 'type element', text: "\n     Type  \n   " }

      context "when the Type Other element in the given data is empty" do
        let(:type_other_element) { double 'type other element', text: '' }

        it "returns nil" do
          expect(pres.type).to eq 'Type'
        end
      end

      context "when the Type Other element in the given data contains text" do
        let(:type_other_element) { double 'type other element', text: "\n     Other Type  \n   " }

        it "returns the Type text with surrounding whitespace removed" do
          expect(pres.type).to eq 'Type'
        end
      end
    end

    context "when the text in the Type element in the given data is 'Other'" do
      let(:type_element) { double 'type element', text: "Other" }

      context "when the Type Other element in the given data is empty" do
        let(:type_other_element) { double 'type other element', text: '' }

        it "returns nil" do
          expect(pres.type).to be_nil
        end
      end

      context "when the Type Other element in the given data contains text" do
        let(:type_other_element) { double 'type other element', text: "\n     Other Type  \n   " }

        it "returns the Type Other text with surrounding whitespace removed" do
          expect(pres.type).to eq 'Other Type'
        end
      end
    end
  end

  describe '#meet_type' do
    before { allow(parsed_pres).to receive(:css).with('MEETTYPE').and_return meet_type_element }

    context "when the Type element in the given data is empty" do
      let(:meet_type_element) { double 'meet type element', text: '' }
      it "returns nil" do
        expect(pres.meet_type).to be_nil
      end
    end

    context "when the Type element in the given data contains text" do
      let(:meet_type_element) { double 'meet type element', text: "\n     Meet Type  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(pres.meet_type).to eq 'Meet Type'
      end
    end
  end

  describe '#attendance' do
    before { allow(parsed_pres).to receive(:css).with('ATTENDANCE').and_return attendance_element }

    context "when the Attendance element in the given data is empty" do
      let(:attendance_element) { double 'attendance element', text: '' }
      it "returns nil" do
        expect(pres.attendance).to be_nil
      end
    end

    context "when the Attendance element in the given data contains text" do
      let(:attendance_element) { double 'attendance element', text: "\n     Attendance  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(pres.attendance).to eq 'Attendance'
      end
    end
  end

  describe '#refereed' do
    before { allow(parsed_pres).to receive(:css).with('REFEREED').and_return refereed_element }

    context "when the Refereed element in the given data is empty" do
      let(:refereed_element) { double 'refereed element', text: '' }
      it "returns nil" do
        expect(pres.refereed).to be_nil
      end
    end

    context "when the Refereed element in the given data contains text" do
      let(:refereed_element) { double 'refereed element', text: "\n     Refereed  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(pres.refereed).to eq 'Refereed'
      end
    end
  end

  describe '#abstract' do
    before { allow(parsed_pres).to receive(:css).with('ABSTRACT').and_return abstract_element }

    context "when the Abstract element in the given data is empty" do
      let(:abstract_element) { double 'abstract element', text: '' }
      it "returns nil" do
        expect(pres.abstract).to be_nil
      end
    end

    context "when the Abstract element in the given data contains text" do
      let(:abstract_element) { double 'abstract element', text: "\n     Abstract  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(pres.abstract).to eq 'Abstract'
      end
    end
  end

  describe '#comment' do
    before { allow(parsed_pres).to receive(:css).with('COMMENT').and_return comment_element }

    context "when the Comment element in the given data is empty" do
      let(:comment_element) { double 'comment element', text: '' }
      it "returns nil" do
        expect(pres.comment).to be_nil
      end
    end

    context "when the Comment element in the given data contains text" do
      let(:comment_element) { double 'comment element', text: "\n     Comment  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(pres.comment).to eq 'Comment'
      end
    end
  end

  describe '#scope' do
    before { allow(parsed_pres).to receive(:css).with('SCOPE').and_return scope_element }

    context "when the Scope element in the given data is empty" do
      let(:scope_element) { double 'scope element', text: '' }
      it "returns nil" do
        expect(pres.scope).to be_nil
      end
    end

    context "when the Scope element in the given data contains text" do
      let(:scope_element) { double 'scope element', text: "\n     Scope  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(pres.scope).to eq 'Scope'
      end
    end
  end

  describe '#started_on' do
    before { allow(parsed_pres).to receive(:css).with('SCOPE').and_return scope_element }

  end
end
