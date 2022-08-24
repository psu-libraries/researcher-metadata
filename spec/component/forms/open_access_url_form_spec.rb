# frozen_string_literal: true

require 'component/component_spec_helper'

describe OpenAccessURLForm do
  let(:form) { described_class.new(open_access_url: url) }

  context 'using a mocked HTTP client for URL validation' do
    let(:response) { double 'response' }

    before do
      allow(HTTParty).to receive(:head).with(
        url,
        follow_redirects: false,
        headers: { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36' }
      ).and_return(response)
    end

    describe '#valid?' do
      context 'when given a blank open access URL' do
        let(:url) { '' }

        it 'returns false' do
          expect(form.valid?).to be false
        end

        it 'sets an error on the attriute' do
          form.valid?
          expect(form.errors[:open_access_url]).to eq [I18n.t('models.open_access_url_form.validation_errors.url_format')]
        end
      end

      context 'when given an open access URL with the wrong scheme' do
        let(:url) { 'ftp://example.com' }

        it 'returns false' do
          expect(form.valid?).to be false
        end

        it 'sets an error on the attriute' do
          form.valid?
          expect(form.errors[:open_access_url]).to eq [I18n.t('models.open_access_url_form.validation_errors.url_format')]
        end
      end

      context 'when given a valid HTTP open access URL' do
        let(:url) { 'http://example.com' }

        before { allow(response).to receive(:code).and_return 200 }

        it 'returns true' do
          expect(form.valid?).to be true
        end
      end

      context 'when given a valid HTTPS open access URL' do
        let(:url) { 'https://example.com' }

        before { allow(response).to receive(:code).and_return 200 }

        it 'returns true' do
          expect(form.valid?).to be true
        end
      end

      context 'when given an open access URL that returns a 301 response' do
        let(:url) { 'https://threeohone.com' }

        before { allow(response).to receive(:code).and_return 301 }

        it 'returns true' do
          expect(form.valid?).to be true
        end
      end

      context 'when given an open access URL that returns a 302 response' do
        let(:url) { 'https://threeohtwo.com' }

        before { allow(response).to receive(:code).and_return 302 }

        it 'returns true' do
          expect(form.valid?).to be true
        end
      end

      context 'when given an open access URL that returns a 404 response' do
        let(:url) { 'https://fake.fake' }

        before { allow(response).to receive(:code).and_return 404 }

        it 'returns false' do
          expect(form.valid?).to be false
        end

        it 'sets an error on the attriute' do
          form.valid?
          expect(form.errors[:open_access_url]).to eq [I18n.t('models.open_access_url_form.validation_errors.url_response')]
        end
      end

      context 'when given an open access URL that raises a TCP connection error' do
        let(:url) { 'https://connection.bad' }

        before do
          allow(HTTParty).to receive(:head).with(
            url,
            follow_redirects: false,
            headers: { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36' }
          ).and_raise SocketError
        end

        it 'sets an error on the attriute' do
          form.valid?
          expect(form.errors[:open_access_url]).to eq [I18n.t('models.open_access_url_form.validation_errors.url_response')]
        end
      end
    end
  end

  # One brittle test for a real-world edge case
  context 'using real HTTP client for URL validation' do
    describe '#valid?' do
      context 'when given a valid HTTP open access URL that does not allow access by certain user agents' do
        let(:url) { 'https://www.sciencedirect.com/science/article/am/pii/S0361923017302502' }

        it 'returns true' do
          expect(form.valid?).to be true
        end
      end
    end
  end
end
