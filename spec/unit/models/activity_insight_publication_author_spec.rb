require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/importers/activity_insight_importer'

describe ActivityInsightPublicationAuthor do
  let(:parsed_auth) { double 'parsed publication author xml' }
  let(:auth) { ActivityInsightPublicationAuthor.new(parsed_auth, user) }
  let(:user) { double 'user', activity_insight_id: '123' }

  describe '#activity_insight_user_id' do
    before { allow(parsed_auth).to receive(:css).with('FACULTY_NAME').and_return faculty_name_element }

    context "when the faculty_name element in the given data is empty" do
      let(:faculty_name_element) { double 'faculty name element', text: '' }
      it "returns nil" do
        expect(auth.activity_insight_user_id).to be_nil
      end
    end

    context "when the faculty_name element in the given data contains text" do
      let(:faculty_name_element) { double 'faculty name element', text: "\n     123456  \n   " }
      it "returns the text with surrounding whitespace removed" do
        expect(auth.activity_insight_user_id).to eq '123456'
      end
    end
  end

  describe '#first_name' do
    before do
      allow(parsed_auth).to receive(:css).with('FACULTY_NAME').and_return faculty_name_element
      allow(parsed_auth).to receive(:css).with('FNAME').and_return fname_element
    end

    context "when the value for FACULTY_NAME matches the ID of the given user" do
      let(:faculty_name_element) { double 'faculty name element', text: '123' }

      context "when the fname element in the given data is empty" do
        let(:fname_element) { double 'first name element', text: '' }
        it "returns nil" do
          expect(auth.first_name).to be_nil
        end
      end

      context "when the fname element in the given data contains text" do
        let(:fname_element) { double 'first name element', text: "\n     First Name  \n   " }
        it "returns the text with surrounding whitespace removed" do
          expect(auth.first_name).to eq 'First Name'
        end
      end
    end

    context "when the value for FACULTY_NAME does not match the ID of the given user" do
      let(:faculty_name_element) { double 'faculty name element', text: '456' }

      context "when the fname element in the given data is empty" do
        let(:fname_element) { double 'first name element', text: '' }
        it "returns nil" do
          expect(auth.first_name).to be_nil
        end
      end

      context "when the fname element in the given data contains text" do
        let(:fname_element) { double 'first name element', text: "\n     First Name  \n   " }
        it "returns the abbreviated first name" do
          expect(auth.first_name).to eq 'F.'
        end
      end
    end

    context "when the author data has no value for FACULTY_NAME" do
      let(:faculty_name_element) { double 'faculty name element', text: '' }

      context "when the fname element in the given data is empty" do
        let(:fname_element) { double 'first name element', text: '' }
        it "returns nil" do
          expect(auth.first_name).to be_nil
        end
      end

      context "when the fname element in the given data contains text" do
        let(:fname_element) { double 'first name element', text: "\n     First Name  \n   " }
        it "returns the text with surrounding whitespace removed" do
          expect(auth.first_name).to eq 'First Name'
        end
      end
    end
  end

  describe '#middle_name' do
    before { allow(parsed_auth).to receive(:css).with('MNAME').and_return mname_element }

    context "when the mname element in the given data is empty" do
      let(:mname_element) { double 'middle name element', text: '' }
      it "returns nil" do
        expect(auth.middle_name).to be_nil
      end
    end

    context "when the mname element in the given data contains text" do
      let(:mname_element) { double 'middle name element', text: "\n     Middle Name  \n   " }
      it "returns the text with surrounding whitespace removed" do
        expect(auth.middle_name).to eq 'Middle Name'
      end
    end
  end

  describe '#last_name' do
    before { allow(parsed_auth).to receive(:css).with('LNAME').and_return lname_element }

    context "when the lname element in the given data is empty" do
      let(:lname_element) { double 'last name element', text: '' }
      it "returns nil" do
        expect(auth.last_name).to be_nil
      end
    end

    context "when the lname element in the given data contains text" do
      let(:lname_element) { double 'last name element', text: "\n     Last Name  \n   " }
      it "returns the text with surrounding whitespace removed" do
        expect(auth.last_name).to eq 'Last Name'
      end
    end
  end

  describe '#role' do
    before { allow(parsed_auth).to receive(:css).with('ROLE').and_return role_element }

    context "when the role element in the given data is empty" do
      let(:role_element) { double 'role element', text: '' }
      it "returns nil" do
        expect(auth.role).to be_nil
      end
    end

    context "when the role element in the given data contains text" do
      let(:role_element) { double 'role element', text: "\n     Role  \n   " }
      it "returns the text with surrounding whitespace removed" do
        expect(auth.role).to eq 'Role'
      end
    end
  end

  describe '#activity_insight_id' do
    let(:id_attr) { double 'id attribute', value: '10'}
    before { allow(parsed_auth).to receive(:attribute).with('id').and_return(id_attr) }
    it "returns the id attribute from the given element" do
      expect(auth.activity_insight_id).to eq '10'
    end
  end

  describe '#==' do
    let(:id_attr) { double 'id attribute', value: '10' }
    let(:other_parsed_auth) { double 'other parsed publication author xml' }
    before { allow(parsed_auth).to receive(:attribute).with('id').and_return(id_attr) }
    
    context "when given an author with the same activity insight ID" do
      let(:other) { ActivityInsightPublicationAuthor.new(other_parsed_auth, double('user')) }
      let(:other_id_attr) { double 'id attribute', value: '10' }
      before { allow(other_parsed_auth).to receive(:attribute).with('id').and_return(other_id_attr) }
      it "returns true" do
        expect(auth == other).to eq true
      end
    end

    context "when given an author with a different activity insight ID" do
      let(:other) { ActivityInsightPublicationAuthor.new(other_parsed_auth, double('user')) }
      let(:other_id_attr) { double 'id attribute', value: '9' }
      before { allow(other_parsed_auth).to receive(:attribute).with('id').and_return(other_id_attr) }
      it "returns false" do
        expect(auth == other).to eq false
      end
    end

    context "when given different kind of object with the same activity insight ID" do
      let(:other) { double 'some object', activity_insight_id: '10' }
      it "returns false" do
        expect(auth == other).to eq false
      end
    end

    context "when given different kind of object with a different activity insight ID" do
      let(:other) { double 'some object', activity_insight_id: '9' }
      it "returns false" do
        expect(auth == other).to eq false
      end
    end
  end
end
