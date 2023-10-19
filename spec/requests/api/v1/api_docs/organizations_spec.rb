# frozen_string_literal: true

require 'requests/requests_spec_helper'

describe 'api/v1/organizations' do
  let!(:org) { create(:organization) }
  let!(:api_token) { create(:api_token, token: 'token123') }
  let!(:user) { create(:user_with_authorships, webaccess_id: 'xyz321', authorships_count: 10) }

  before do
    create(:organization_api_permission, api_token: api_token, organization: org)
    create(:user_organization_membership, organization: org, user: user)
  end

  path '/v1/organizations' do
    get 'All Organizations' do
      description 'Returns all visible organizations to which the given API token has access.'
      operationId 'findOrganizations'
      produces 'application/json'
      tags 'organization'
      response 200, 'organization response' do
        let(:'X-API-Key') { 'token123' }
        schema type: :object,
               properties: {
                 data: { type: :array,
                         items:
                           { properties:
                            { id: {
                                type: :string,
                                example: '123',
                                description: 'The ID of the object'
                              },
                              type: {
                                type: :string,
                                example: 'organization',
                                description: 'The type of object'
                              },
                              attributes: {
                                type: :object,
                                required: ['name'],
                                properties: {
                                  name: {
                                    type: :string,
                                    example: 'College of Engineering',
                                    description: 'The name of the organization'
                                  }
                                }
                              } },
                             type: :object,
                             required: ['id', 'type', 'attributes'] } }
               },
               required: ['data']
        security [api_key: []]
        run_test!
      end

      response 401, 'unauthorized' do
        let(:'X-API-Key') { 'bogus' }
        schema '$ref' => '#/components/schemas/ErrorModelV1'
        run_test!
      end
    end
  end

  path '/v1/organizations/{id}/publications' do
    let(:id) { org.id }
    parameter name: 'id',
              in: :path,
              type: :integer,
              description: 'The ID of an organization',
              required: true
    parameter name: 'offset',
              in: :query,
              description: 'The number of items to skip before starting to collect the result set',
              required: false,
              schema: {
                type: :integer,
                format: :int32
              }
    parameter name: 'limit',
              in: :query,
              description: 'The numbers of items to return',
              required: false,
              schema: {
                type: :integer,
                format: :int32
              }

    get "Retrieve an organization's publications" do
      description 'Returns publications that were authored by users while they were members of the organization'
      operationId 'findOrganizationPublications'
      produces 'application/json'
      tags 'organization'
      response 200, 'user publication response' do
        let(:'X-API-Key') { 'token123' }
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
        let(:'X-API-Key') { 'bogus' }
        schema '$ref' => '#/components/schemas/ErrorModelV1'
        run_test!
      end

      response 404, 'not found' do
        let(:'X-API-Key') { 'token123' }
        let(:id) { org.id + 1 }
        schema '$ref' => '#/components/schemas/ErrorModelV1'
        run_test!
      end
    end
  end
end
