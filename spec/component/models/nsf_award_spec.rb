# frozen_string_literal: true

require 'component/component_spec_helper'

describe NSFAward do
  let(:award) { described_class.new(award_data) }
  let(:award_data) {
    {
      'title' => 'Test Title',
      'startDate' => start_date,
      'expDate' => end_date,
      'abstractText' => 'test abstract',
      'fundsObligatedAmt' => amount,
      'id' => '12345',
      'piFirstName' => first_name,
      'piLastName' => last_name,
      'piMiddeInitial' => middle_initial,
      'piEmail' => email,
      'jrnl' => publications
    }
  }
  let(:start_date) { nil }
  let(:end_date) { nil }
  let(:amount) { nil }
  let(:first_name) { nil }
  let(:last_name) { nil }
  let(:middle_initial) { nil }
  let(:email) { nil }
  let(:publications) { nil }

  describe '#title' do
    it 'returns the award title from the given data' do
      expect(award.title).to eq 'Test Title'
    end
  end

  describe '#start_date' do
    context 'when there is no start date in the given data' do
      it 'returns nil' do
        expect(award.start_date).to be_nil
      end
    end

    context 'when there is a start date in the given data' do
      let(:start_date) { '01/01/2026' }

      it 'returns the start date' do
        expect(award.start_date).to eq Date.new(2026, 1, 1)
      end
    end
  end

  describe '#end_date' do
    context 'when there is no end date in the given data' do
      it 'returns nil' do
        expect(award.end_date).to be_nil
      end
    end

    context 'when there is a end date in the given data' do
      let(:end_date) { '01/01/2026' }

      it 'returns the end date' do
        expect(award.end_date).to eq Date.new(2026, 1, 1)
      end
    end
  end

  describe '#abstract' do
    it 'returns the award abstract from the given data' do
      expect(award.abstract).to eq 'test abstract'
    end
  end

  describe '#amount_in_dollars' do
    context 'when there is no award amount in the given data' do
      it 'returns nil' do
        expect(award.amount_in_dollars).to be_nil
      end
    end

    context 'when there is an award amount in the given data' do
      let(:amount) { '45000' }

      it 'returns the amount' do
        expect(award.amount_in_dollars).to eq 45000
      end
    end
  end

  describe '#identifier' do
    it 'returns the award identifier from the given data' do
      expect(award.identifier).to eq '12345'
    end
  end

  describe '#agency_name' do
    it "returns 'National Science Foundation'" do
      expect(award.agency_name).to eq 'National Science Foundation'
    end
  end

  describe '#pi_first_name' do
    context 'when there is no principal investigator first name in the given data' do
      it 'returns nil' do
        expect(award.pi_first_name).to be_nil
      end
    end

    context 'when there is a principal investigator first name in the given data' do
      let(:first_name) { 'First' }

      it 'returns the first name' do
        expect(award.pi_first_name).to eq 'First'
      end
    end
  end

  describe '#pi_last_name' do
    context 'when there is no principal investigator last name in the given data' do
      it 'returns nil' do
        expect(award.pi_last_name).to be_nil
      end
    end

    context 'when there is a principal investigator last name in the given data' do
      let(:last_name) { 'Last' }

      it 'returns the last name' do
        expect(award.pi_last_name).to eq 'Last'
      end
    end
  end

  describe '#pi_middle_initial' do
    context 'when there is no principal investigator middle initial in the given data' do
      it 'returns nil' do
        expect(award.pi_middle_initial).to be_nil
      end
    end

    context 'when there is a principal investigator middle initial in the given data' do
      let(:middle_initial) { 'M' }

      it 'returns the middle initial' do
        expect(award.pi_middle_initial).to eq 'M'
      end
    end
  end

  describe '#pi_psu_email_name' do
    context 'when there is no principal investigator email address in the given data' do
      it 'returns nil' do
        expect(award.pi_psu_email_name).to be_nil
      end
    end

    context 'when the principal investigator email address in the given data is blank' do
      let(:email) { '' }

      it 'returns nil' do
        expect(award.pi_psu_email_name).to be_nil
      end
    end

    context 'when there is a principal investigator email address in the given data' do
      context 'when the email address is at the psu.edu domain' do
        let(:email) { 'abc123@psu.edu' }

        it 'returns the first part of the email address' do
          expect(award.pi_psu_email_name).to eq 'abc123'
        end
      end

      context 'when the email address is at a psu.edu subdomain' do
        let(:email) { 'abc123@anything.psu.edu' }

        it 'returns the first part of the email address' do
          expect(award.pi_psu_email_name).to eq 'abc123'
        end
      end

      context 'when the email address is at a non-psu.edu domain' do
        let(:email) { 'abc123@msu.edu' }

        it 'returns nil' do
          expect(award.pi_psu_email_name).to be_nil
        end
      end
    end
  end

  describe '#publications' do
    context 'when there is no publication metadata in the given data' do
      it 'returns an empty array' do
        expect(award.publications).to eq []
      end
    end

    context 'when there is publication metadata in the given data' do
      let(:publications) { [p1, p2] }
      let(:p1) { double 'publication metadata' }
      let(:p2) { double 'publication metadata' }
      let(:nsf_pub1) { instance_double NSFAwardPublication }
      let(:nsf_pub2) { instance_double NSFAwardPublication }

      before do
        allow(NSFAwardPublication).to receive(:new).with(p1).and_return nsf_pub1
        allow(NSFAwardPublication).to receive(:new).with(p2).and_return nsf_pub2
      end

      it 'returns an NSFAwardPublication for every publication in the metadata' do
        expect(award.publications).to eq [nsf_pub1, nsf_pub2]
      end
    end
  end
end
