# frozen_string_literal: true

module API::V1
  class OrganizationsController < APIController
    # include Swagger::Blocks

    def index
      render json: API::V1::OrganizationSerializer.new(api_token.organizations.visible)
    end

    def publications
      org = api_token.organizations.visible.find(params[:id])
      render json: API::V1::PublicationSerializer.new(org.all_publications)
    end

#     swagger_path '/v1/organizations' do
#       operation :get do
#         key :summary, 'All Organizations'
#         key :description, 'Returns all visible organizations to which the given API token has access.'
#         key :operationId, 'findOrganizations'
#         key :produces, ['application/json']
#         key :tags, ['organization']
#         response 200 do
#           key :description, 'organization response'
#           schema do
#             key :required, [:data]
#             property :data do
#               key :type, :array
#               items do
#                 key :type, :object
#                 key :required, [:id, :type, :attributes]
#                 property :id do
#                   key :type, :string
#                   key :example, '123'
#                   key :description, 'The ID of the object'
#                 end
#                 property :type do
#                   key :type, :string
#                   key :example, 'organization'
#                   key :description, 'The type of the object'
#                 end
#                 property :attributes do
#                   key :type, :object
#                   key :required, [:name]
#                   property :name do
#                     key :type, :string
#                     key :example, 'College of Engineering'
#                     key :description, 'The name of the organization'
#                   end
#                 end
#               end
#             end
#           end
#         end
#         response 401 do
#           key :description, 'unauthorized'
#           schema do
#             key :$ref, :ErrorModelV1
#           end
#         end
#         security do
#           key :api_key, []
#         end
#       end
#     end

#     swagger_path '/v1/organizations/{id}/publications' do
#       operation :get do
#         key :summary, "Retrieve an organization's publications"
#         key :description, 'Returns publications that were authored by users while they were members of the organization'
#         key :operationId, 'findOrganizationPublications'
#         key :produces, ['application/json']
#         key :tags, ['organization']
#         parameter do
#           key :name, :id
#           key :in, :path
#           key :description, 'The ID of an organization'
#           key :required, true
#           key :type, :integer
#         end
#         response 200 do
#           key :description, 'user publications response'
#           schema do
#             key :required, [:data]
#             property :data do
#               key :type, :array
#               items do
#                 key :$ref, :PublicationV1
#               end
#             end
#           end
#         end
#         response 401 do
#           key :description, 'unauthorized'
#           schema do
#             key :$ref, :ErrorModelV1
#           end
#         end
#         response 404 do
#           key :description, 'not found'
#           schema do
#             key :$ref, :ErrorModelV1
#           end
#         end
#         security do
#           key :api_key, []
#         end
#       end
#     end
  end
end
