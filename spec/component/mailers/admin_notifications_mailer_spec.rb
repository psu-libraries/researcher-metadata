# frozen_string_literal: true

require 'component/component_spec_helper'

describe AdminNotificationsMailer, type: :model do
  describe '#authorship_claim' do
    subject(:email) { described_class.authorship_claim(auth) }

    let(:auth) { double 'authorship',
                        title: 'The Publication Title',
                        user_name: 'Test User',
                        id: 7 }

    before do
      allow(ActionMailer::Base).to receive(:default_url_options).and_return({ host: 'example.com' })
    end

    it 'sends the email to the correct admin email address' do
      expect(email.to).to eq ['rmd-admin@psu.edu']
    end

    it 'sends the email from the correct address' do
      expect(email.from).to eq ['openaccess@psu.edu']
    end

    it 'sends the email with the correct subject' do
      expect(email.subject).to eq 'RMD Authorship Claim'
    end

    describe 'the message body' do
      let(:body) { email.body.raw_source }

      it 'shows the name of the user who claimed the publication' do
        expect(body).to match(auth.user_name)
      end

      it 'shows the title of the claimed publication' do
        expect(body).to match(auth.title)
      end

      it 'shows a link to edit the authorship' do
        expect(body).to match RailsAdmin.railtie_routes_url_helpers.edit_url(model_name: :authorship, id: 7, host: 'example.com')
      end
    end
  end

  describe '#pure_import_error' do
    subject(:email) { described_class.pure_import_error }

    before do
      allow(ActionMailer::Base).to receive(:default_url_options).and_return({ host: 'example.com' })
    end

    it 'sends the email to the correct admin email address' do
      expect(email.to).to eq ['rmd-admin@psu.edu']
    end

    it 'sends the email from the correct address' do
      expect(email.from).to eq ['openaccess@psu.edu']
    end

    it 'sends the email with the correct subject' do
      expect(email.subject).to eq 'Pure Import Error'
    end

    describe 'the message body' do
      let(:body) { email.body.raw_source }

      it 'names the error' do
        expect(body).to match('404 Service Not Found')
      end
    end
  end
end
