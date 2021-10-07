require 'component/component_spec_helper'

describe OpenAccessURLForm do
  let(:form) { OpenAccessURLForm.new(open_access_url: url) }
  let(:response) { double 'response' }

  before do
    allow(HTTParty).to receive(:head).with(url, follow_redirects: false).and_return(response)
  end

  describe '#valid?' do
    context 'when given a blank open access URL' do
      let(:url) { '' }

      it 'returns false' do
        expect(form.valid?).to eq false
      end

      it 'sets an error on the attriute' do
        form.valid?
        expect(form.errors[:open_access_url]).to eq [I18n.t('models.open_access_url_form.validation_errors.url_format')]
      end
    end

    context 'when given an open access URL with the wrong scheme' do
      let(:url) { 'ftp://example.com' }

      it 'returns false' do
        expect(form.valid?).to eq false
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
        expect(form.valid?).to eq true
      end
    end

    context 'when given a valid HTTPS open access URL' do
      let(:url) { 'https://example.com' }

      before { allow(response).to receive(:code).and_return 200 }

      it 'returns true' do
        expect(form.valid?).to eq true
      end
    end

    context 'when given an open access URL that returns a 301 response' do
      let(:url) { 'https://threeohone.com' }

      before { allow(response).to receive(:code).and_return 301 }

      it 'returns true' do
        expect(form.valid?).to eq true
      end
    end

    context 'when given an open access URL that returns a 302 response' do
      let(:url) { 'https://threeohtwo.com' }

      before { allow(response).to receive(:code).and_return 302 }

      it 'returns true' do
        expect(form.valid?).to eq true
      end
    end

    context 'when given an open access URL that returns a 404 response' do
      let(:url) { 'https://fake.fake' }

      before { allow(response).to receive(:code).and_return 404 }

      it 'returns false' do
        expect(form.valid?).to eq false
      end

      it 'sets an error on the attriute' do
        form.valid?
        expect(form.errors[:open_access_url]).to eq [I18n.t('models.open_access_url_form.validation_errors.url_response')]
      end
    end

    context 'when given an open access URL that raises a TCP connection error' do
      let(:url) { 'https://connection.bad' }

      before do
        allow(HTTParty).to receive(:head).with(url, follow_redirects: false).and_raise SocketError
      end

      it 'sets an error on the attriute' do
        form.valid?
        expect(form.errors[:open_access_url]).to eq [I18n.t('models.open_access_url_form.validation_errors.url_response')]
      end
    end
  end
end
