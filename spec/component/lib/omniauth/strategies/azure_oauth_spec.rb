# frozen_string_literal: true

require 'component/component_spec_helper'

describe OmniAuth::Strategies::AzureOauth do
  let(:app) { double 'rack app' }
  let(:strategy) { described_class.new(app) }
  let(:client) { double 'oauth2 client' }
  let(:access_token) { { 'id_token' => "prefix.#{Base64.encode64(auth_hash.to_json)}" } }
  let(:auth_hash) { { upn: 'abc123@psu.edu' } }

  before do
    strategy.access_token = OAuth2::AccessToken.from_hash(client, access_token)
  end

  describe '.default_params' do
    it 'returns the correct default params' do
      expect(described_class.default_options[:authorize_params][:domain_hint]).to eq 'psu.edu'
      expect(described_class.default_options[:client_options][:site]).to eq 'http://example.test'
      expect(described_class.default_options[:client_options][:token_url]).to eq '/test/oauth2/v2.0/token'
      expect(described_class.default_options[:client_options][:authorize_url]).to eq '/test/oauth2/v2.0/authorize'
      expect(described_class.default_options[:name]).to eq :azure_oauth
    end
  end

  describe '#callback_url' do
    xit
  end

  describe '#uid' do
    it "returns user's WebAccess ID that's parsed out of the access token" do
      expect(strategy.uid).to eq 'abc123'
    end
  end
end
