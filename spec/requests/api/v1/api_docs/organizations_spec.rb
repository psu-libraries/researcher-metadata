# frozen_string_literal: true

require 'requests/requests_spec_helper'

describe 'api/v1/organizations' do
  path '/v1/organizations' do
    get 'All Organizations' do
      description 'Returns all visible organizations to which the given API token has access.'
      operationId 'findOrganizations'
      produces 'application/json'
      tags 'organization'
      response 200, 'organization response' do
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
                                         description: 'The type of object' },
                                 attributes: { type: :object,
                                               required: ['name'],
                                               properties: { name: { type: :string,
                                                                     example: 'College of Engineering',
                                                                     description: 'The name of the organization' } } } },
                             type: :object,
                             required: ['id', 'type', 'attributes'] } }
               },
               required: ['data']
        security [api_key: []]
        run_test!
      end

      response 401, 'unauthorized' do
        schema '$ref' => '#/components/schemas/ErrorModelV1'
        run_test!
      end
    end
  end

  path '/v1/organizations/{id}/publications' do
    parameter name: 'id', in: :path, type: :integer, description: 'The ID of an organization', required: true

    get "Retrieve an organization's publications" do
      description 'Returns publications that were authored by users while they were members of the organization'
      operationId 'findOrganizationPublications'
      produces 'application/json'
      tags 'organization'
      response 200, 'user publication response' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     '$ref' => '#/components/schemas/PublicationV1'
                   }
                 }
               }

        security [api_key: []]
        run_test!
      end

      response 401, 'unauthorized' do
        schema '$ref' => '#/components/schemas/ErrorModelV1'
        run_test!
      end

      response 404, 'not found' do
        schema '$ref' => '#/components/schemas/ErrorModelV1'
        run_test!
      end
    end
  end
end
