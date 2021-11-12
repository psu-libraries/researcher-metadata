# frozen_string_literal: true

require 'component/component_spec_helper'

describe DeputyAssignmentsMailer, type: :model do
  let(:primary) { double 'user',
                         email: 'primary@psu.edu',
                         name: 'Primary User',
                         webaccess_id: 'abc123' }

  let(:deputy) { double 'user',
                        email: 'deputy@psu.edu',
                        name: 'Deputy User',
                        webaccess_id: 'def456' }

  let(:deputy_assignment) { double 'deputy_assignment',
                                   primary: primary,
                                   deputy: deputy }

  describe '#deputy_assignment_confirmation' do
    subject(:email) { described_class.deputy_assignment_confirmation(deputy_assignment) }

    it "sends the email to the primary user's email address" do
      expect(email.to).to eq ['primary@psu.edu']
    end

    it 'sends the email from the correct address' do
      expect(email.from).to eq ['openaccess@psu.edu']
    end

    it 'sends the email with the correct subject' do
      expect(email.subject).to eq 'PSU Researcher Metadata Database - Proxy Request Confirmed'
    end

    it 'sets the correct reply-to address' do
      expect(email.reply_to).to eq ['openaccess@psu.edu']
    end

    describe 'the message body' do
      let(:body) { email.body.raw_source }

      it 'addresses the user by name' do
        expect(body).to include('Dear Primary User,')
      end

      it 'mentions the deputy by name and webaccess ID' do
        expect(body).to include('Deputy User (def456)')
      end
    end
  end

  describe '#deputy_assignment_declination' do
    subject(:email) { described_class.deputy_assignment_declination(deputy_assignment) }

    it "sends the email to the primary user's email address" do
      expect(email.to).to eq ['primary@psu.edu']
    end

    it 'sends the email from the correct address' do
      expect(email.from).to eq ['openaccess@psu.edu']
    end

    it 'sends the email with the correct subject' do
      expect(email.subject).to eq 'PSU Researcher Metadata Database - Proxy Request Declined'
    end

    it 'sets the correct reply-to address' do
      expect(email.reply_to).to eq ['openaccess@psu.edu']
    end

    describe 'the message body' do
      let(:body) { email.body.raw_source }

      it 'addresses the user by name' do
        expect(body).to include('Dear Primary User,')
      end

      it 'mentions the deputy by name and webaccess ID' do
        expect(body).to include('Deputy User (def456)')
      end
    end
  end

  describe '#deputy_assignment_request' do
    subject(:email) { described_class.deputy_assignment_request(deputy_assignment) }

    before do
      allow(ActionMailer::Base).to receive(:default_url_options).and_return({ host: 'example.com' })
    end

    it "sends the email to the deputy user's email address" do
      expect(email.to).to eq ['deputy@psu.edu']
    end

    it 'sends the email from the correct address' do
      expect(email.from).to eq ['openaccess@psu.edu']
    end

    it 'sends the email with the correct subject' do
      expect(email.subject).to eq 'PSU Researcher Metadata Database - Proxy Assignment Request'
    end

    it 'sets the correct reply-to address' do
      expect(email.reply_to).to eq ['openaccess@psu.edu']
    end

    describe 'the message body' do
      let(:body) { email.body.raw_source }

      it 'addresses the user by name' do
        expect(body).to include('Dear Deputy User,')
      end
    end
  end

  describe '#deputy_status_ended' do
    subject(:email) { described_class.deputy_status_ended(deputy_assignment) }

    it "sends the email to the primary user's email address" do
      expect(email.to).to eq ['primary@psu.edu']
    end

    it 'sends the email from the correct address' do
      expect(email.from).to eq ['openaccess@psu.edu']
    end

    it 'sends the email with the correct subject' do
      expect(email.subject).to eq 'PSU Researcher Metadata Database - Proxy Status Ended'
    end

    it 'sets the correct reply-to address' do
      expect(email.reply_to).to eq ['openaccess@psu.edu']
    end

    describe 'the message body' do
      let(:body) { email.body.raw_source }

      it 'addresses the user by name' do
        expect(body).to include('Dear Primary User,')
      end

      it 'mentions the deputy by name and webaccess ID' do
        expect(body).to include('Deputy User (def456)')
      end
    end
  end

  describe '#deputy_status_revoked' do
    subject(:email) { described_class.deputy_status_revoked(deputy_assignment) }

    it "sends the email to the deputy user's email address" do
      expect(email.to).to eq ['deputy@psu.edu']
    end

    it 'sends the email from the correct address' do
      expect(email.from).to eq ['openaccess@psu.edu']
    end

    it 'sends the email with the correct subject' do
      expect(email.subject).to eq 'PSU Researcher Metadata Database - Proxy Status Revoked'
    end

    it 'sets the correct reply-to address' do
      expect(email.reply_to).to eq ['openaccess@psu.edu']
    end

    describe 'the message body' do
      let(:body) { email.body.raw_source }

      it 'addresses the user by name' do
        expect(body).to include('Dear Deputy User,')
      end

      it 'mentions the primary user by name and webaccess ID' do
        expect(body).to include('Primary User (abc123)')
      end
    end
  end
end
