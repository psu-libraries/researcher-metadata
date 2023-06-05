require 'requests/requests_spec_helper'

RSpec.describe 'api/v1/organizations', type: :request do
  before do
    create(:organization)
    create(:api_token, token: 'token123', total_requests: 0, last_used_at: nil)
  end

  path '/v1/organizations' do

    get('All Organizations') do
      description 'Returns all visible organizations to which the given API token has access.'
      operationId 'findOrganizations'
      produces 'application/json'
      tags 'organization'
      security [ api_key: [] ]
      response(200, 'organization response') do
        let(:'X-API-Key') { 'token123' }
        schema type: :object,
          properties: {
            data: { type: :array,
                    items: 
                      { properties: 
                          { id: { type: :string,
                                  example: '123',
                                  description: 'The ID of the object' },
                            type: { type: :string,
                                    example: 'organization',
                                    description: 'The type of object'},
                            attributes: { type: :object,
                                          required: ['name'],
                                          properties: { name: { type: :string,
                                                                example: 'College of Engineering',
                                                                description: 'The name of the organization' 
                                                              }
                                                      }
                                        } 
                            },
                          type: :object,
                          required: ['id', 'type', 'attributes']
                      },
                  }
            },
            required: ['data']
          run_test! 
        end

        response(401, 'unauthorized') do
          let(:'X-API-Key') { 'invalid' }
          schema '$ref' => '#/components/schemas/ErrorModelV1'
          run_test!
        end
      end
    end

  # path '/v1/organizations/{id}/publications' do
  #   # You'll want to customize the parameter types...
  #   parameter name: 'id', in: :path, type: :string, description: 'id'

  #   get('publications organization') do
  #     response(200, 'successful') do
  #       let(:id) { '123' }

  #       after do |example|
  #         example.metadata[:response][:content] = {
  #           'application/json' => {
  #             example: JSON.parse(response.body, symbolize_names: true)
  #           }
  #         }
  #       end
  #       run_test!
  #     end
  #   end
  # end
end
