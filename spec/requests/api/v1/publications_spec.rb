require 'swagger_helper'

RSpec.describe 'api/v1/publications', type: :request do

  path '/v1/publications' do

    path '/v1/publications/{id}/grants' do
      get("Retrieve a publication's grants") do
        description 'Returns grant data associated with a publication'
        operationId 'findPublicationGrants'
        tags ['publication']
        produces ['application/json']
        parameter name: :id, in: :path, description: 'ID of publication to retrieve grants', required: true, type: :string
  
        response '200', 'publication grants response' do
          schema type: :object, properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                required: [:id, :type, :attributes],
                properties: {
                  id: { type: :string, example: '123', description: 'The ID of the object' },
                  type: { type: :string, example: 'grant', description: 'The type of the object' },
                  attributes: {
                    type: :object,
                    required: [:title, :agency, :abstract, :amount_in_dollars, :start_date, :end_date, :identifier],
                    properties: {
                      title: { type: [:string, :null], example: 'A Research Project Proposal', description: 'The title of the grant' },
                      agency: { type: [:string, :null], example: 'National Science Foundation', description: 'The name of the organization that awarded the grant' },
                      abstract: { type: [:string, :null], example: 'Information about this grant', description: "A description of the grant's purpose" },
                      amount_in_dollars: { type: [:integer, :null], example: 50000, description: 'The monetary amount of the grant in U.S. dollars' },
                      start_date: { type: [:string, :null], example: '2017-12-05', description: 'The date on which the grant begins' },
                      end_date: { type: [:string, :null], example: '2019-12-05', description: 'The date on which the grant ends' },
                      identifier: { type: [:string, :null], example: '1789352', description: 'A code identifying the grant that is unique to the awarding agency' }
                    }
                  }
                }
              }
            }
          },
          required: ['data']
          run_test!
        end
  
        response '401', 'unauthorized' do
          schema '$ref' => '#/components/schemas/ErrorModelV1'
          run_test!
        end
  
        response '404', 'not found' do
          schema '$ref' => '#/components/schemas/ErrorModelV1'
          run_test!
        end
  
        security [api_key: []]
      end
    end

    get('list publications') do
      
    end

    patch('update_all publication') do
      response(200, 'successful') do

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/v1/publications/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show publication') do
      response(200, 'successful') do
        let(:id) { '123' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end
end
