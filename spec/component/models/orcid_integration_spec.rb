# frozen_string_literal: true

require 'component/component_spec_helper'

describe OrcidAPIClient do
  let(:client) { described_class.new(resource) }
  # Access token and orcid id for orcidtest@pennteam.m8r.co sandbox account
  let(:resource) { double 'ORCID Resource',
                          access_token: '98768b7f-c177-4c24-9fe8-b575997e2bc7',
                          orcid_id: '0000-0002-5925-6081',
                          orcid_type: 'employment',
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

  describe 'integrating with ORCID', glacial: true do
    let(:headers) {
      {
        headers:
          { 'Content-type' => 'application/vnd.orcid+json',
            'Authorization' => "Bearer #{resource.access_token}" }
      }
    }
    let(:employments_uri) { "#{described_class.base_uri}/#{resource.orcid_id}/employments" }
    let(:get_employments) { client.class.get(employments_uri, headers).parsed_response }
    let(:employments_hash) { JSON.parse(get_employments) }
    let(:json_resource) { JSON.parse(resource.to_json) }
    let(:employment_path) do
      employments_hash['affiliation-group'].max_by { |l| l['summaries'].last['employment-summary']['path'] }
      ['summaries'].last['employment-summary']['path']
    end
    let(:employment_summary) { employments_hash['affiliation-group'].last['summaries'].last['employment-summary'] }

    after do
      delete_employ_uri = employments_uri[0..-2].to_s + "/#{employment_summary['put_code']}"
      client.class.delete(delete_employ_uri, headers)
    end

    it 'successfully POSTs to ORCID and does not return an error' do
      post = client.post
      expect(post.response.message).to eq 'Created'
      expect(post['location']).to include employment_path
      expect(employment_summary['department-name']).to eq json_resource['department-name']
      expect(employment_summary['role-title']).to eq json_resource['role-title']
      expect(employment_summary['organization']['disambiguated-organization']).to eq json_resource['organization']['disambiguated-organization']
    end
  end
end
