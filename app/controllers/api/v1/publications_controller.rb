module API::V1
  class PublicationsController < APIController
    include Swagger::Blocks

    def index
      limit = params[:limit].presence || 100
      render json: API::V1::PublicationSerializer.new(api_token.publications.visible.limit(limit))
    end

    def show
      @publication = api_token.publications.visible.find(params[:id])
      render json: API::V1::PublicationSerializer.new(@publication).serializable_hash
    end

    def grants
      publication = api_token.publications.visible.find(params[:id])
      render json: API::V1::GrantSerializer.new(publication.grants)
    end

    swagger_path '/v1/publications/{id}/grants' do
      operation :get do
        key :summary, "Retrieve a publication's grants"
        key :description, 'Returns grant data associated with a publication'
        key :operationId, 'findPublicationGrants'
        key :produces, ['application/json']
        key :tags, ['publication']
        parameter do
          key :name, :id
          key :in, :path
          key :description, 'ID of publication to retrieve grants'
          key :required, true
          key :type, :string
        end

        response 200 do
          key :description, 'publication grants response'
          schema do
            key :required, [:data]
            property :data do
              key :type, :array
              items do
                key :type, :object
                key :required, [:id, :type, :attributes]
                property :id do
                  key :type, :string
                  key :example, '123'
                  key :description, 'The ID of the object'
                end
                property :type do
                  key :type, :string
                  key :example, 'grant'
                  key :description, 'The type of the object'
                end
                property :attributes do
                  key :type, :object
                  key :required, [:title, :agency, :abstract, :amount_in_dollars,
                                  :start_date, :end_date, :identifier]
                  property :title do
                    key :type, [:string, :null]
                    key :example, 'A Research Project Proposal'
                    key :description, 'The title of the grant'
                  end
                  property :agency do
                    key :type, [:string, :null]
                    key :example, 'National Science Foundation'
                    key :description, 'The name of the organization that awarded the grant'
                  end
                  property :abstract do
                    key :type, [:string, :null]
                    key :example, 'Information about this grant'
                    key :description, "A description of the grant's purpose"
                  end
                  property :amount_in_dollars do
                    key :type, [:integer, :null]
                    key :example, 50000
                    key :description, 'The monetary amount of the grant in U.S. dollars'
                  end
                  property :start_date do
                    key :type, [:string, :null]
                    key :example, '2017-12-05'
                    key :description, 'The date on which the grant begins'
                  end
                  property :end_date do
                    key :type, [:string, :null]
                    key :example, '2019-12-05'
                    key :description, 'The date on which the grant ends'
                  end
                  property :identifier do
                    key :type, [:string, :null]
                    key :example, '1789352'
                    key :description, 'A code identifying the grant that is unique to the awarding agency'
                  end
                end
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
          'text/html'
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
