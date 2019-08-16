module API::V1
  class PublicationsController < APIController
    include Swagger::Blocks

    def index
      params[:limit].present? ? limit = params[:limit] : limit = 100
      render json: API::V1::PublicationSerializer.new(api_token.publications.visible.limit(limit))
    end

    def show
      @publication = api_token.publications.visible.find(params[:id])
      render json: API::V1::PublicationSerializer.new(@publication).serializable_hash
    end

    swagger_path '/v1/publications/{id}' do
      operation :get do
        key :summary, 'Find Publication by ID'
        key :description, 'Returns a single publication if the user has access'
        key :operationId, 'findPublicationById'
        key :tags, [
          'publication'
        ]
        parameter do
          key :name, :id
          key :in, :path
          key :description, 'ID of publication to fetch'
          key :required, true
          key :type, :integer
          key :format, :int64
        end
        response 200 do
          key :description, 'publication response'
          schema do
            key :required, [:data]
            property :data do
              key :type, :object
              key :'$ref', :PublicationV1
            end
          end
        end
        response 401 do
          key :description, 'unauthorized'
          schema do
            key :'$ref', :ErrorModelV1
          end
        end
        response 404 do
          key :description, 'not found'
          schema do
            key :'$ref', :ErrorModelV1
          end
        end
        security do
          key :api_key, []
        end
      end
    end

    swagger_path '/v1/publications' do
      operation :get do
        key :summary, 'All Publications'
        key :description, 'Returns all publications from the system that the user has access to'
        key :operationId, 'findPublications'
        key :produces, [
          'application/json',
          'text/html',
        ]
        key :tags, [
          'publication'
        ]
        parameter do
          key :name, :limit
          key :in, :query
          key :description, 'max number publications to return'
          key :required, false
          key :type, :integer
          key :format, :int32
        end
        response 200 do
          key :description, 'publication response'
          schema do
            key :required, [:data]
            property :data do
              key :type, :array
              items do
                key :'$ref', :PublicationV1
              end
            end
          end
        end
        response 401 do
          key :description, 'unauthorized'
          schema do
            key :'$ref', :ErrorModelV1
          end
        end
        security do
          key :api_key, []
        end
      end
    end
  end
end
