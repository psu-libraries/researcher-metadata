module API::V1
  class UsersController < APIController
    include Swagger::Blocks

    def publications
      params[:limit].present? ? limit = params[:limit] : limit = 100
      user = User.find_by(webaccess_id: params[:webaccess_id])
      if user
        render json: API::V1::PublicationSerializer.new(user.publications.limit(limit))
      else
        render json: { :message => "User not found", :code => 404 }, status: 404
      end
    end

    swagger_path '/v1/users/{webaccess_id}/publications' do
      operation :get do
        key :summary, "Retrieve a user's publications"
        key :description, 'Returns a publications for a user'
        key :operationId, 'findUserPublications'
        key :tags, [
          'user',
          'publications'
        ]
        parameter do
          key :name, :webaccess_id
          key :in, :path
          key :description, 'ID of user to retrieve publications'
          key :required, true
          key :type, :string
        end
        parameter do
          key :name, :limit
          key :in, :query
          key :description, 'max number publications to return'
          key :required, false
          key :type, :integer
          key :format, :int32
        end
        response 200 do
          key :description, 'user publications response'
          schema do
            key :'$ref', :User
          end
        end
        response 404 do
          key :description, 'not found'
          schema do
            key :'$ref', :User
            key :required, [:code, :message]
            property :code do
              key :type, :integer
              key :format, :int32
            end
            property :message do
              key :type, :string
            end
          end
        end
      end
    end
  end
end
