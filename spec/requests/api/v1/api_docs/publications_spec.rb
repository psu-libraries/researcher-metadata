# frozen_string_literal: true

require 'requests/requests_spec_helper'

RSpec.describe 'api/v1/publications' do
  let!(:user) { create(:user_with_authorships, webaccess_id: 'xyz321') }
  let!(:authorship) { create(:authorship, user: user, publication: publication) }
  let!(:publication) { create(:publication, visible: true, doi: 'https://doi.org/10.1000/182') }
  let!(:api_token) { create(:api_token, token: 'token123', write_access: true) }
  let!(:grant) { create(:grant) }
  let!(:research_fund) { create(:research_fund, grant: grant, publication: publication) }
  let!(:org) { create(:organization) }

  before do
    create(:organization_api_permission, api_token: api_token, organization: org)
    create(:user_organization_membership, organization: org, user: user)
  end

  path '/v1/publications' do
    path '/v1/publications/{id}/grants' do
      let(:id) { publication.id }
      get "Retrieve a publication's grants" do
        description 'Returns grant data associated with a publication'
        operationId 'findPublicationGrants'
        tags 'publication'
        produces 'application/json'
        parameter name: :id, in: :path, description: 'ID of publication to retrieve grants', required: true, type: :string

        response 200, 'publication grants response' do
          let(:'X-API-Key') { 'token123' }
          schema type: :object, properties: {
                                  data: {
                                    type: :array,
                                    items: {
                                      type: :object,
                                      required: [:id, :type, :attributes],
                                      properties: {
                                        id: { 
                                          type: :string,
                                          example: '123',
                                          description: 'The ID of the object'
                                        },
                                        type: { 
                                          type: :string,
                                          example: 'grant',
                                          description: 'The type of the object' 
                                        },
                                        attributes: {
                                          type: :object,
                                          required: [:title, :agency, :abstract,
                                                     :amount_in_dollars, :start_date,
                                                     :end_date, :identifier],
                                          properties: {
                                            title: { 
                                              type: [:string, :null],
                                              example: 'A Research Project Proposal',
                                              description: 'The title of the grant' 
                                            },
                                            agency: { 
                                              type: [:string, :null],
                                              example: 'National Science Foundation',
                                              description: 'The name of the organization that awarded the grant' 
                                            },
                                            abstract: { 
                                              type: [:string, :null],
                                              example: 'Information about this grant',
                                              description: "A description of the grant's purpose" 
                                            },
                                            amount_in_dollars: { 
                                              type: [:integer, :null],
                                              example: 50000,
                                              description: 'The monetary amount of the grant in U.S. dollars' 
                                            },
                                            start_date: { 
                                              type: [:string, :null],
                                              example: '2017-12-05',
                                              description: 'The date on which the grant begins' 
                                            },
                                            end_date: { 
                                              type: [:string, :null],
                                              example: '2019-12-05',
                                              description: 'The date on which the grant ends' 
                                            },
                                            identifier: { 
                                              type: [:string, :null],
                                              example: '1789352',
                                              description: 'A code identifying the grant that is unique to the awarding agency' 
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                },
                 required: ['data']
          run_test!
        end

        response 401, 'unauthorized' do
          let(:'X-API-Key') { 'bogus' }
          schema '$ref' => '#/components/schemas/ErrorModelV1'
          run_test!
        end

        response 404, 'not found' do
          let(:'X-API-Key') { 'token123' }
          let(:id) { publication.id + 1 }
          schema '$ref' => '#/components/schemas/ErrorModelV1'
          run_test!
        end

        security [api_key: []]
      end
    end

    path '/v1/publications/{id}' do
      let(:id) { publication.id }
      parameter name: :id, 
                in: :path, 
                description: 'ID of publication to fetch', 
                required: true, 
                type: :integer, 
                format: :int64

      get 'Find Publication by ID' do
        tags 'publication'
        description 'Returns a single publication if the user has access'
        operationId 'findPublicationById'

        response 200, 'publication response' do
          let(:'X-API-Key') { 'token123' }
          schema type: :object, properties: {
            data: { type: :object, '$ref' => '#/components/schemas/PublicationV1' }
          }
          run_test!
        end

        response 401, 'unauthorized' do
          let(:'X-API-Key') { 'bogus' }
          schema '$ref' => '#/components/schemas/ErrorModelV1'
          run_test!
        end

        response 404, 'not found' do
          let(:'X-API-Key') { 'token123' }
          let(:id) { publication.id + 1 }
          schema '$ref' => '#/components/schemas/ErrorModelV1'
          run_test!
        end

        security [api_key: []]
      end
    end

    path '/v1/publications' do
      let(:Publication) { { doi: publication.doi } }
      get 'All Publications' do
        tags 'publication'
        description 'Returns all publications from the system that the user has access to'
        operationId 'findPublications'
        produces 'application/json', 'text/html'

        parameter name: :activity_insight_id,
                  in: :query,
                  description: 'Activity Insight ID to filter by',
                  required: false,
                  type: :string
        parameter name: :doi,
                  in: :query,
                  description: 'DOI to filter by',
                  required: false,
                  type: :string
        parameter name: :limit,
                  in: :query,
                  description: 'max number publications to return',
                  required: false,
                  type: :integer, format: :int32

        response 200, 'publication response' do
          let(:'X-API-Key') { 'token123' }
          schema type: :object,
                 properties: {
                   data: {
                     type: :array,
                     items: { '$ref' => '#/components/schemas/PublicationV1' }
                   }
                 },
                 required: ['data']
          run_test!
        end

        response 401, 'unauthorized' do
          let(:'X-API-Key') { 'bogus' }
          schema '$ref' => '#/components/schemas/ErrorModelV1'
          run_test!
        end

        security [{ api_key: [] }]
      end

      patch 'Update publication\'s ScholarSphere Open Access Link' do
        tags 'publication'
        description 'Update publication\'s ScholarSphere Open Access Link by doi or activity insight id'
        operationId 'updateOpenAccessLink'
        produces 'application/json'

        parameter name: 'Publication',
                  in: :body,
                  required: true,
                  description: 'ScholarSphere Open Access Link update requires either a doi or an activity insight id',
                  schema: { '$ref' => '#/components/schemas/PublicationInput' }

        response 200, 'ScholarSphere Open Access Link successfully updated response' do
          let(:'X-API-Key') { 'token123' }
          let(:Publication) { { doi: publication.doi, scholarsphere_open_access_url: 'url.com' } }
          schema '$ref' => '#/components/schemas/PublicationPatchResult'
          run_test!
        end

        response 401, 'Unauthorized' do
          let(:'X-API-Key') { 'bogus' }
          schema '$ref' => '#/components/schemas/ErrorModelV1'
          run_test!
        end

        response 404, 'No publications found response' do
          let(:'X-API-Key') { 'token123' }
          let(:Publication) { { doi: 'some bogus doi', scholarsphere_open_access_url: 'url.com' } }
          schema '$ref' => '#/components/schemas/ErrorModelV1'
          run_test!
        end

        response 422, 'ScholarSphere Open Access Link already exists response' do
          before do
            publication.open_access_locations << create(:open_access_location, source: 'scholarsphere', url: 'url.com')
            publication.save!
          end
          let(:'X-API-Key') { 'token123' }
          let(:Publication) { { doi: publication.doi, scholarsphere_open_access_url: 'url.com' } }
          schema '$ref' => '#/components/schemas/ErrorModelV1'
          run_test!
        end

        response 422, 'Invalid params response' do
          let(:'X-API-Key') { 'token123' }
          let(:Publication) { { wrong_param: 'wrong', scholarsphere_open_access_url: 'url.com' } }
          schema '$ref' => '#/components/schemas/ErrorModelV1'
          run_test!
        end

        security [{ api_key: [] }]
      end
    end
  end
end
