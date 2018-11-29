module API::V1
  class UsersController < APIController
    include Swagger::Blocks
    include ActionController::MimeResponds

    def presentations
      user = User.find_by(webaccess_id: params[:webaccess_id])
      if user
        @presentations = API::V1::UserQuery.new(user).presentations(params)
        respond_to do |format|
          format.html
          format.json { render json: API::V1::PresentationSerializer.new(@presentations) }
        end
      else
        render json: { :message => "User not found", :code => 404 }, status: 404
      end
    end

    def contracts
      user = User.find_by(webaccess_id: params[:webaccess_id])
      if user
        @contracts = API::V1::UserQuery.new(user).contracts(params)
        respond_to do |format|
          format.html
          format.json { render json: API::V1::ContractSerializer.new(@contracts) }
        end
      else
        render json: { :message => "User not found", :code => 404 }, status: 404
      end
    end

    def news_feed_items
      user = User.find_by(webaccess_id: params[:webaccess_id])
      if user
        @news_feed_items = API::V1::UserQuery.new(user).news_feed_items(params)
        respond_to do |format|
          format.html
          format.json { render json: API::V1::NewsFeedItemSerializer.new(@news_feed_items) }
        end
      else
        render json: { :message => "User not found", :code => 404 }, status: 404
      end
    end

    def etds
      @user = User.find_by(webaccess_id: params[:webaccess_id])
      if @user
        @etds = API::V1::UserQuery.new(@user).etds(params)
        respond_to do |format|
          format.html
          format.json { render json: API::V1::ETDSerializer.new(@etds) }
        end
      else
        render json: { :message => "User not found", :code => 404 }, status: 404
      end
    end

    def publications
      user = User.find_by(webaccess_id: params[:webaccess_id])
      if user
        @pubs = API::V1::UserQuery.new(user).publications(params)
        respond_to do |format|
          format.html
          format.json { render json: API::V1::PublicationSerializer.new(@pubs) }
        end
      else
        render json: { :message => "User not found", :code => 404 }, status: 404
      end
    end

    def organization_memberships
      user = User.find_by(webaccess_id: params[:webaccess_id])
      if user
        @memberships = user.user_organization_memberships
        respond_to do |format|
          format.html
          format.json { render json: API::V1::OrganizationMembershipSerializer.new(@memberships) }
        end
      else
        render json: { :message => "User not found", :code => 404 }, status: 404
      end
    end

    def profile
      @user = User.find_by(webaccess_id: params[:webaccess_id])
      uq = API::V1::UserQuery.new(@user)
      if @user
        @pubs = uq.publications({order_first_by: 'publication_date_desc'})
        @grants = uq.contracts.where(status: 'Awarded', contract_type: 'Grant').order(award_start_on: :desc)
        @presentations = uq.presentations({})
        @news_feed_items = uq.news_feed_items({}).order(published_on: :desc)
        @committee_memberships = @user.committee_memberships
      else
        render json: { :message => "User not found", :code => 404 }, status: 404
      end
    end

    def users_publications
      data = {}
      User.includes(:publications).where(webaccess_id: params[:_json]).each do |user|
        pubs = API::V1::UserQuery.new(user).publications(params)
        data[user.webaccess_id] = API::V1::PublicationSerializer.new(pubs).serializable_hash
      end
      render json: data
    end

    swagger_path '/v1/users/{webaccess_id}/organization_memberships' do
      operation :get do
        key :summary, "Retrieve the user's organization memberships"
        key :description, 'Returns organization memberships for a user'
        key :operationId, 'findUserOrganizationMemberships'
        key :produces, [
          'application/json'
        ]
        key :tags, [
          'user'
        ]
        parameter do
          key :name, :webaccess_id
          key :in, :path
          key :description, 'Webaccess ID of user to retrieve organization memberships'
          key :required, true
          key :type, :string
        end
        response 200 do
          key :description, 'user organization memberships response'
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

    swagger_path '/v1/users/{webaccess_id}/news_feed_items' do
      operation :get do
        key :summary, "Retrieve a user's news feed items"
        key :description, 'Returns a news feed items for a user'
        key :operationId, 'findUserNewsFeedItems'
        key :produces, [
          'application/json',
          'text/html'
        ]
        key :tags, [
          'user'
        ]
        parameter do
          key :name, :webaccess_id
          key :in, :path
          key :description, 'Webaccess ID of user to retrieve news feed items'
          key :required, true
          key :type, :string
        end
         response 200 do
          key :description, 'user news_feed_items response'
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

    swagger_path '/v1/users/{webaccess_id}/presentations' do
      operation :get do
        key :summary, "Retrieve a user's presentations"
        key :description, 'Returns presentations for a user'
        key :operationId, 'findUserPresentations'
        key :produces, [
          'application/json',
          'text/html'
        ]
        key :tags, [
          'user'
        ]
        parameter do
          key :name, :webaccess_id
          key :in, :path
          key :description, 'Webaccess ID of user to retrieve contracts'
          key :required, true
          key :type, :string
        end

        response 200 do
          key :description, 'user presentations response'
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

    swagger_path '/v1/users/{webaccess_id}/contracts' do
      operation :get do
        key :summary, "Retrieve a user's contracts"
        key :description, 'Returns a contracts for a user'
        key :operationId, 'findUserContracts'
        key :produces, [
          'application/json',
          'text/html'
        ]
        key :tags, [
          'user'
        ]
        parameter do
          key :name, :webaccess_id
          key :in, :path
          key :description, 'Webaccess ID of user to retrieve contracts'
          key :required, true
          key :type, :string
        end

        response 200 do
          key :description, 'user contracts response'
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

    swagger_path '/v1/users/{webaccess_id}/etds' do
      operation :get do
        key :summary, "Retrieve a user's student advising history"
        key :description, 'Returns ETDs for which the user served on the committee'
        key :operationId, 'findUserETDs'
        key :produces, [
          'application/json',
          'text/html'
        ]
        key :tags, [
          'user'
        ]
        parameter do
          key :name, :webaccess_id
          key :in, :path
          key :description, 'Webaccess ID of user to retrieve ETDs'
          key :required, true
          key :type, :string
        end

        response 200 do
          key :description, 'user ETDs response'
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

    swagger_path '/v1/users/{webaccess_id}/publications' do
      operation :get do
        key :summary, "Retrieve a user's publications"
        key :description, 'Returns a publications for a user'
        key :operationId, 'findUserPublications'
        key :produces, [
          'application/json',
          'text/html'
        ]
        key :tags, [
          'user'
        ]
        parameter do
          key :name, :webaccess_id
          key :in, :path
          key :description, 'Webaccess ID of user to retrieve publications'
          key :required, true
          key :type, :string
        end
        parameter do
          key :name, :start_year
          key :in, :query
          key :description, 'Beginning of publication year range'
          key :required, false
          key :type, :integer
          key :format, :int32
        end
        parameter do
          key :name, :end_year
          key :in, :query
          key :description, 'End of publication year range'
          key :required, false
          key :type, :integer
          key :format, :int32
        end
        parameter do
          key :name, :order_first_by
          key :in, :query
          key :description, 'Orders publications returned'
          key :required, false
          key :type, :string
          key :enum, [
            :citation_count_desc,
            :publication_date_asc,
            :publication_date_desc,
            :title_asc
          ]
        end
        parameter do
          key :name, :order_second_by
          key :in, :query
          key :description, 'Orders publications returned'
          key :required, false
          key :type, :string
          key :enum, [
            :citation_count_desc,
            :publication_date_asc,
            :publication_date_desc,
            :title_asc
          ]
        end
        parameter do
          key :name, :limit
          key :in, :query
          key :description, 'Max number publications to return for the user'
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

    swagger_path '/v1/users/{webaccess_id}/profile' do
      operation :get do
        key :summary, "Retrieve a user's profile"
        key :description, "Returns a plain HTML representation of a user's profile information"
        key :operationId, 'findUserProfile'
        key :produces, ['text/html']
        key :tags, ['user']

        parameter do
          key :name, :webaccess_id
          key :in, :path
          key :description, 'Webaccess ID of user to retrieve publications'
          key :required, true
          key :type, :string
        end

        response 200 do
          key :description, 'user profile response'
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

    swagger_path '/v1/users/publications' do
      operation :post do
        key :summary, "Retrieve publications for a group of users"
        key :description, 'Returns publications for a group of users'
        key :operationId, 'findUsersPublications'
        key :tags, [
          'user'
        ]
        parameter do
          key :name, :start_year
          key :in, :query
          key :description, 'Beginning of publication year range'
          key :required, false
          key :type, :integer
          key :format, :int32
        end
        parameter do
          key :name, :end_year
          key :in, :query
          key :description, 'End of publication year range'
          key :required, false
          key :type, :integer
          key :format, :int32
        end
        parameter do
          key :name, :order_first_by
          key :in, :query
          key :description, 'Orders publications returned'
          key :required, false
          key :type, :string
          key :enum, [
            :citation_count_desc,
            :publication_date_asc,
            :publication_date_desc,
            :title_asc
          ]
        end
        parameter do
          key :name, :order_second_by
          key :in, :query
          key :description, 'Orders publications returned'
          key :required, false
          key :type, :string
          key :enum, [
            :citation_count_desc,
            :publication_date_asc,
            :publication_date_desc,
            :title_asc
          ]
        end
        parameter do
          key :name, :limit
          key :in, :query
          key :description, 'Max number publications to return for each user'
          key :required, false
          key :type, :integer
          key :format, :int32
        end
        parameter do
          key :in, 'body'
          key :description, 'Webaccess IDs of users to retrieve publications'
          key :required, true
          key :name, :webaccess_ids
          schema do
            key :type, :array
            items do
              key :type, :string
            end
          end
        end
        response 200 do
          key :description, 'OK'
        end
      end
    end
  end
end
