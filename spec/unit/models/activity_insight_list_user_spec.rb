require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/importers/activity_insight_importer'

describe ActivityInsightListUser do
  let(:parsed_user) { double 'parsed user xml' }
  let(:user) { ActivityInsightListUser.new(parsed_user) }

  describe '#raw_webaccess_id' do
    let(:username_attr) { double 'username attribute', value: 'ABC123' }
    before { allow(parsed_user).to receive(:attribute).with('username').and_return(username_attr) }
    it "returns the username attribute from the given data" do
      expect(user.raw_webaccess_id).to eq 'ABC123'
    end
  end

  describe '#webaccess_id' do
    let(:username_attr) { double 'username attribute', value: 'ABC123' }
    before { allow(parsed_user).to receive(:attribute).with('username').and_return(username_attr) }
    it "returns the username attribute from the given data in all lower case" do
      expect(user.webaccess_id).to eq 'abc123'
    end
  end

  describe '#activity_insight_id' do
    let(:ai_id_attr) { double 'activity insight id attribute', value: '123456' }
    before { allow(parsed_user).to receive(:attribute).with('userId').and_return(ai_id_attr) }
    it "returns the username attribute from the given data in all lower case" do
      expect(user.activity_insight_id).to eq '123456'
    end
  end

  describe '#penn_state_id' do
    context "when the given data has a PSU ID attribute" do
      let(:psu_id_attr) { double 'penn state id attribute', value: '654321' }
      before { allow(parsed_user).to receive(:attribute).with('PSUIDFacultyOnly').and_return(psu_id_attr) }
      it "returns the PSU ID attribute from the given data" do
        expect(user.penn_state_id).to eq '654321'
      end
    end

    context "when the given data does not have a PSU ID attribute" do
      before { allow(parsed_user).to receive(:attribute).with('PSUIDFacultyOnly').and_return(nil) }
      it "returns nil" do
        expect(user.penn_state_id).to be_nil
      end
    end
  end

  describe '#first_name' do
    before { allow(parsed_user).to receive(:css).with('FirstName').and_return(fn_element) }

    context "when the First Name element in the given data is empty" do
      let(:fn_element) { double 'first name element', text: '' }
      it "returns nil" do
        expect(user.first_name).to be_nil
      end
    end

    context "when the First Name element in the given data contains text" do
      let(:fn_element) { double 'first name element', text: "\n     First  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(user.first_name).to eq 'First'
      end
    end
  end

  describe '#middle_name' do
    before { allow(parsed_user).to receive(:css).with('MiddleName').and_return(mn_element) }

    context "when the Middle Name element in the given data is empty" do
      let(:mn_element) { double 'middle name element', text: '' }
      it "returns nil" do
        expect(user.middle_name).to be_nil
      end
    end

    context "when the Middle Name element in the given data contains text" do
      let(:mn_element) { double 'middle name element', text: "\n     Middle  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(user.middle_name).to eq 'Middle'
      end
    end
  end

  describe '#last_name' do
    before { allow(parsed_user).to receive(:css).with('LastName').and_return(ln_element) }

    context "when the Last Name element in the given data is empty" do
      let(:ln_element) { double 'last name element', text: '' }
      it "returns nil" do
        expect(user.last_name).to be_nil
      end
    end

    context "when the Last Name element in the given data contains text" do
      let(:ln_element) { double 'last name element', text: "\n     Last  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(user.last_name).to eq 'Last'
      end
    end
  end
end
