require 'component/component_spec_helper'

describe NSFInvestigator do
  let(:parsed_investigator) { double 'parsed investigator xml' }
  let(:investigator) { NSFInvestigator.new(parsed_investigator) }

  describe '#first_name' do
    before { allow(parsed_investigator).to receive(:css).with('FirstName').and_return first_name_element }

    context "when the first name element in the given data is empty" do
      let(:first_name_element) { double 'first name element', text: '' }
      it "returns nil" do
        expect(investigator.first_name).to be_nil
      end
    end

    context "when the first name element in the given data contains text" do
      let(:first_name_element) { double 'first name element', text: "\n     Jennifer  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(investigator.first_name).to eq 'Jennifer'
      end
    end
  end

  describe '#last_name' do
    before { allow(parsed_investigator).to receive(:css).with('LastName').and_return last_name_element }

    context "when the last name element in the given data is empty" do
      let(:last_name_element) { double 'last name element', text: '' }
      it "returns nil" do
        expect(investigator.last_name).to be_nil
      end
    end

    context "when the last name element in the given data contains text" do
      let(:last_name_element) { double 'last name element', text: "\n     Testuser  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(investigator.last_name).to eq 'Testuser'
      end
    end
  end

  describe '#psu_email_name' do
    before { allow(parsed_investigator).to receive(:css).with('EmailAddress').and_return email_element }

    context "when the email element in the given data is empty" do
      let(:email_element) { double 'email element', text: '' }
      it "returns nil" do
        expect(investigator.psu_email_name).to be_nil
      end
    end

    context "when the email element in the given data contains text with a non-PSU email address" do
      let(:email_element) { double 'email element', text: "\n     user123@msu.edu  \n   " }

      it "returns nil" do
        expect(investigator.psu_email_name).to be_nil
      end
    end
    context "when the email element in the given data contains text with a PSU email address" do
      let(:email_element) { double 'email element', text: "\n     user456@psu.edu  \n   " }

      it "returns the name part of the email address with any surrounding whitepace removed" do
        expect(investigator.psu_email_name).to eq 'user456'
      end
    end
  end
end
