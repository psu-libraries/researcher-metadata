require 'component/component_spec_helper'

describe OrcidAPIClient do
  let(:client) { OrcidAPIClient.new(resource) }
  # Access token and orcid id for orcidtest@pennteam.m8r.co sandbox account
  let(:resource) { double 'ORCID Resource',
                          access_token: "98768b7f-c177-4c24-9fe8-b575997e2bc7",
                          orcid_id: "0000-0002-5925-6081",
                          orcid_type: "employment",
                          to_json: %{{
                                      "department-name": "test",
                                      "role-title": "test",
                                      "organization":
                                        {
                                          "name": "test",
                                          "address":
                                            {
                                              "city": "Test City",
                                              "country": "US"
                                            },
                                          "disambiguated-organization":
                                            {
                                              "disambiguation-source": "RINGGOLD",
                                              "disambiguated-organization-identifier": "385488"
                                            }
                                        }
                                     }}
  }

  describe "integrating with ORCID", glacial: true do
    it "successfully POSTs to ORCID and does not return an error" do
      expect(client.post.parsed_response).to eq nil
    end
  end
end
