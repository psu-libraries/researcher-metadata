require 'component/component_spec_helper'

describe OrcidOauthClient do
  let(:client) { OrcidOauthClient.new }

  describe '#create_token' do
    it 'sends a post request to the ORCID API with the correct data and headers' do
      expect(OrcidOauthClient).to receive(:post).with('/token',
                                                      {
                                                        headers: { 'Accept' => 'application/json' },
                                                        body: {
                                                          client_id: 'test',
                                                          client_secret: 'secret',
                                                          grant_type: 'authorization_code',
                                                          code: 'abc123'
                                                        }
                                                      })
      client.create_token('abc123')
    end
  end
end
