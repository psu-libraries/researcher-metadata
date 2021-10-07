require 'component/component_spec_helper'

describe OrcidAPIClient do
  let(:client) { OrcidAPIClient.new(resource) }
  let(:resource) { double 'ORCID resource',
                          access_token: 'abc123',
                          orcid_id: '0000-0000-1234-5678',
                          orcid_type: 'employment',
                          to_json: %{{"employment": "data"}} }

  describe '#post' do
    it 'sends a post request to the ORCID API with the correct data and headers' do
      expect(OrcidAPIClient).to receive(:post).with('/0000-0000-1234-5678/employment',
                                                    {
                                                      headers: {
                                                        'Content-type' => 'application/vnd.orcid+json',
                                                        'Authorization' => 'Bearer abc123'
                                                      },
                                                      body: %{{"employment": "data"}}
                                                    })
      client.post
    end
  end
end
