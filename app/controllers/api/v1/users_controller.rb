module API::V1
  class UsersController < APIController
    include Swagger::Blocks
    include ActionController::MimeResponds

    def presentations
      user = api_token.users.find_by(webaccess_id: params[:webaccess_id])
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

    def news_feed_items
      user = api_token.users.find_by(webaccess_id: params[:webaccess_id])
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

    def performances
      user = api_token.users.find_by(webaccess_id: params[:webaccess_id])
      if user
        @performances = API::V1::UserQuery.new(user).performances(params)
        respond_to do |format|
          format.html
          format.json { render json: API::V1::PerformanceSerializer.new(@performances) }
        end
      else
        render json: { :message => "User not found", :code => 404 }, status: 404
      end
    end

    def etds
      @user = api_token.users.find_by(webaccess_id: params[:webaccess_id])
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
      user = api_token.users.find_by(webaccess_id: params[:webaccess_id])
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
      user = api_token.users.find_by(webaccess_id: params[:webaccess_id])
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
      headers['Access-Control-Allow-Origin'] = '*' if Rails.env.development?

      user = User.find_by(webaccess_id: params[:webaccess_id])
      if user
        @profile = UserProfile.new(user)
        respond_to do |format|
          format.html
          format.json { render json: API::V1::UserProfileSerializer.new(@profile) }
        end
      else
        render json: { :message => "User not found", :code => 404 }, status: 404
      end
    end

    def users_publications
      data = {}
      api_token.users.includes(:publications).where(webaccess_id: params[:_json]).each do |user|
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
                  key :example, 'organization_membership'
                  key :description, 'The type of the object'
                end
                property :attributes do
                  key :type, :object
                  key :required, [:organization_name]
                  property :organization_name do
                    key :type, :string
                    key :example, 'Biology'
                    key :description, 'The name of the organization to which the user belongs'
                  end
                  property :organization_type do
                    key :type, [:string, :null]
                    key :example, 'Department'
                    key :description, 'The type of the organization'
                  end
                  property :position_title do
                    key :type, [:string, :null]
                    key :example, 'Associate Professor of Biology'
                    key :description, "The user's role or title within the organization"
                  end
                  property :position_started_on do
                    key :type, [:string, :null]
                    key :example, '2010-09-01'
                    key :description, 'The date on which the user joined the organization in this role'
                  end
                  property :position_ended_on do
                    key :type, [:string, :null]
                    key :example, '2012-05-30'
                    key :description, 'The date on which the user left the organization in this role'
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
                  key :example, 'news_feed_item'
                  key :description, 'The type of the object'
                end
                property :attributes do
                  key :type, :object
                  key :required, [:title, :url, :description, :published_on]
                  property :title do
                    key :type, :string
                    key :example, 'News Story'
                    key :description, 'The title of the news feed item'
                  end
                  property :url do
                    key :type, :string
                    key :example, 'https://news.psu.edu/example'
                    key :description, 'The URL where the full news story content can be found'
                  end
                  property :description do
                    key :type, :string
                    key :example, 'A news story about a Penn State researcher'
                    key :description, 'A brief description of the news story content'
                  end
                  property :published_on do
                    key :type, :string
                    key :example, '2018-12-05'
                    key :description, 'The date on which the news story was published'
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
          key :description, 'Webaccess ID of user to retrieve presentations'
          key :required, true
          key :type, :string
        end

        response 200 do
          key :description, 'user presentations response'
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
                  key :example, 'presentation'
                  key :description, 'The type of the object'
                end
                property :attributes do
                  key :type, :object
                  key :required, [:activity_insight_identifier]
                  property :title do
                    key :type, [:string, :null]
                    key :example, 'A Public Presentation'
                    key :description, 'The title of the presentation'
                  end
                  property :activity_insight_identifier do
                    key :type, :string
                    key :example, '1234567890'
                    key :description, "The unique identifier for the presentation's corresponding record in the Activity Insight database"
                  end
                  property :name do
                    key :type, [:string, :null]
                    key :example, 'A Public Presentation'
                    key :description, 'The name of the presentation'
                  end
                  property :organization do
                    key :type, [:string, :null]
                    key :example, 'The Pennsylvania State University'
                    key :description, 'The name of the organization associated with the presentation'
                  end
                  property :location do
                    key :type, [:string, :null]
                    key :example, 'University Park, PA'
                    key :description, 'The name of the location where the presentation took place'
                  end
                  property :started_on do
                    key :type, [:string, :null]
                    key :example, '2018-12-04'
                    key :description, 'The date on which the presentation started'
                  end
                  property :ended_on do
                    key :type, [:string, :null]
                    key :example, '2018-12-05'
                    key :description, 'The date on which the presentation ended'
                  end
                  property :presentation_type do
                    key :type, [:string, :null]
                    key :example, 'Presentations'
                    key :description, 'The type of the presentation'
                  end
                  property :classification do
                    key :type, [:string, :null]
                    key :example, 'Basic or Discovery Scholarship'
                    key :description, 'The classification of the presentation'
                  end
                  property :meet_type do
                    key :type, [:string, :null]
                    key :example, 'Academic'
                    key :description, 'The meet type of the presentation'
                  end
                  property :attendance do
                    key :type, [:integer, :null]
                    key :example, 200
                    key :description, 'The number of people who attended the presentation'
                  end
                  property :refereed do
                    key :type, [:string, :null]
                    key :example, 'Yes'
                    key :description, 'Whether or not the presentation was refereed'
                  end
                  property :abstract do
                    key :type, [:string, :null]
                    key :example, 'A presentation about Penn State academic research'
                    key :description, 'A summary of the presentation content'
                  end
                  property :comment do
                    key :type, [:string, :null]
                    key :example, 'The goal of this presentation was to broaden public awareness of a research topic.'
                    key :description, 'Miscellaneous comments and notes about the presentation'
                  end
                  property :scope do
                    key :type, [:string, :null]
                    key :example, 'International'
                    key :description, 'The scope of the audience for the presentation'
                  end
                  property :profile_preferences do
                    key :type, :array
                    key :description, 'An array of settings for each user who is an author of the publication indicating how they prefer to have the publication displayed in a profile'
                    items do
                      key :type, :object
                      key :required, [:user_id, :webaccess_id, :visible_in_profile, :position_in_profile]
                      property :user_id do
                        key :type, :number
                        key :example, 123
                        key :description, 'The ID of the user to which this set of preferences belongs'
                      end
                      property :webaccess_id do
                        key :type, :string
                        key :example, 'abc123'
                        key :description, 'The WebAccess ID of the user to which this set of preferences belongs'
                      end
                      property :visible_in_profile do
                        key :type, :boolean
                        key :example, true
                        key :description, "The user's preference for whether or not this publication should be displayed in their profile"
                      end
                      property :position_in_profile do
                        key :type, [:number, :null]
                        key :example, 8
                        key :description, "The user's preference for what position this publication should occupy in a list of their publications in their profile"
                      end
                    end
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

    swagger_path '/v1/users/{webaccess_id}/performances' do
      operation :get do
        key :summary, "Retrieve a user's performances"
        key :description, 'Returns performances for a user'
        key :operationId, 'findPerformances'
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
          key :description, 'Webaccess ID of user to retrieve performancess'
          key :required, true
          key :type, :string
        end
         response 200 do
          key :description, 'user performances response'
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
                  key :example, 'performance'
                  key :description, 'The type of the object'
                end
                property :attributes do
                  key :type, :object
                  key :required, [:title, :activity_insight_id]
                  property :title do
                    key :type, :string
                    key :example, 'Example Performance'
                    key :description, 'The title of the performance'
                  end
                  property :activity_insight_id do
                    key :type, :integer
                    key :example, '1234567890'
                    key :description, "The unique identifier for the performances's corresponding record in the Activity Insight database"
                  end
                  property :performance_type do
                    key :type, [:string, :null]
                    key :example, 'Film - Documentary'
                    key :description, 'The type of performance'
                  end
                  property :sponsor do
                    key :type, [:string, :null]
                    key :example, 'Penn State'
                    key :description, 'The the organization that is sponsoring this performance'
                  end
                  property :description do
                    key :type, [:string, :null]
                    key :example, 'This is a unique performance, performed for specific reasons'
                    key :description, 'Any further detail describing the performance'
                  end
                  property :group_name do
                    key :type, [:string, :null]
                    key :example, 'Penn State Performers'
                    key :description, 'The name of the performing group'
                  end
                  property :location do
                    key :type, [:string, :null]
                    key :example, 'State College, PA'
                    key :description, 'Country, State, City, theatre, etc. that the performance took place'
                  end
                  property :delivery_type do
                    key :type, [:string, :null]
                    key :example, 'Competition'
                    key :description, 'Audition, commission, competition, or invitation'
                  end
                  property :scope do
                    key :type, [:string, :null]
                    key :example, 'Local'
                    key :description, 'International, national, regional, state, local'
                  end
                  property :start_on do
                    key :type, [:string, :null]
                    key :example, '12-01-2015'
                    key :description, 'The date that the performance started on'
                  end
                  property :end_on do
                    key :type, [:string, :null]
                    key :example, '12-31-2015'
                    key :description, 'The date that the performance ended on'
                  end
                  property :user_performances do
                    key :type, :array
                    items do
                      key :type, :object
                      property :first_name do
                        key :type, [:string, :null]
                        key :example, 'Billy'
                        key :description, 'The first name of a contributor'
                      end
                      property :last_name do
                        key :type, [:string, :null]
                        key :example, 'Bob'
                        key :description, 'The last name of a contributor'
                      end
                      property :contribution do
                        key :type, [:string, :null]
                        key :example, 'Performer'
                        key :description, 'The contributors role/contribution to the performance'
                      end
                      property :student_level do
                        key :type, [:string, :null]
                        key :example, 'Graduate'
                        key :description, 'Undergraduate or graduate'
                      end
                      property :role_other do
                        key :type, [:string, :null]
                        key :example, 'Director'
                        key :description, 'Role not listed in "contribution" drop-down'
                      end
                    end
                  end
                  property :performance_screenings do
                    key :type, :array
                    items do
                      key :type, :object
                      property :name do
                        key :type, [:string, :null]
                        key :example, 'Film Festival'
                        key :description, 'Name of the venue for the screening'
                      end
                      property :location do
                        key :type, [:string, :null]
                        key :example, 'State College, PA'
                        key :description, 'Country, State, City, that the screening took place'
                      end
                      property :screening_type do
                        key :type, [:string, :null]
                        key :example, 'DVD Distribution'
                        key :description, 'Type of screening/exhibition'
                      end
                    end
                  end
                  property :profile_preferences do
                    key :type, :array
                    key :description, 'An array of settings for each user who is an author of the publication indicating how they prefer to have the publication displayed in a profile'
                    items do
                      key :type, :object
                      key :required, [:user_id, :webaccess_id, :visible_in_profile, :position_in_profile]
                      property :user_id do
                        key :type, :number
                        key :example, 123
                        key :description, 'The ID of the user to which this set of preferences belongs'
                      end
                      property :webaccess_id do
                        key :type, :string
                        key :example, 'abc123'
                        key :description, 'The WebAccess ID of the user to which this set of preferences belongs'
                      end
                      property :visible_in_profile do
                        key :type, :boolean
                        key :example, true
                        key :description, "The user's preference for whether or not this publication should be displayed in their profile"
                      end
                      property :position_in_profile do
                        key :type, [:number, :null]
                        key :example, 8
                        key :description, "The user's preference for what position this publication should occupy in a list of their publications in their profile"
                      end
                    end
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
                  key :example, 'etd'
                  key :description, 'The type of the object'
                end
                property :attributes do
                  key :type, :object
                  key :required, [:title, :year, :author_last_name, :author_first_name]
                  property :title do
                    key :type, :string
                    key :example, 'A PhD Thesis'
                    key :description, 'The title of the ETD'
                  end
                  property :year do
                    key :type, :integer
                    key :example, '2010'
                    key :description, 'The year in which the ETD was completed'
                  end
                  property :author_last_name do
                    key :type, :string
                    key :example, 'Author'
                    key :description, "The last name of the ETD's author"
                  end
                  property :author_first_name do
                    key :type, :string
                    key :example, 'Susan'
                    key :description, "The first name of the ETD's author"
                  end
                  property :author_middle_name do
                    key :type, [:string, :null]
                    key :example, 'Example'
                    key :description, "The first name of the ETD's author"
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

    swagger_path '/v1/users/{webaccess_id}/profile' do
      operation :get do
        key :summary, "Retrieve a user's profile"
        key :description, "Returns a representation of a user's profile information"
        key :operationId, 'findUserProfile'
        key :produces, ['application/json', 'text/html']
        key :tags, ['user']

        parameter do
          key :name, :webaccess_id
          key :in, :path
          key :description, 'Webaccess ID of user to retrieve HTML profile'
          key :required, true
          key :type, :string
        end

        response 200 do
          key :description, 'user profile response'
          schema do
            key :required, [:data]
            property :data do
              key :type, :object
              key :required, [:id, :type, :attributes]
              property :id do
                key :type, :string
                key :example, '123'
                key :description, 'The ID of the user'
              end
              property :type do
                key :type, :string
                key :example, 'user_profile'
                key :description, 'The type of the object'
              end
              property :attributes do
                key :type, :object
                key :required, [:name, :organization_name, :title, :email, :office_location,
                                :office_phone_number, :personal_website, :total_scopus_citations,
                                :scopus_h_index, :pure_profile_url, :orcid_identifier, :bio,
                                :teaching_interests, :research_interests, :publications, :grants,
                                :presentations, :performances, :master_advising_roles,
                                :phd_advising_roles, :news_stories, :education_history]
                property :name do
                  key :type, :string
                  key :example, 'Example User'
                  key :description, 'The full name of the user'
                end
                property :organization_name do
                  key :type, :string
                  key :example, 'College of Engineering'
                  key :description, "The name of the user's primary organization"
                end
                property :title do
                  key :type, :string
                  key :example, 'Professor'
                  key :description, "The title of the user's position"
                end
                property :email do
                  key :type, :string
                  key :example, 'abc123@psu.edu'
                  key :description, "The user's email address"
                end
                property :office_location do
                  key :type, :string
                  key :example, '101 Chemistry Building'
                  key :description, "The room number and building where the user's office is located"
                end
                property :office_phone_number do
                  key :type, :string
                  key :example, '(555) 555-555'
                  key :description, "The telephone number for the user's office"
                end
                property :personal_website do
                  key :type, :string
                  key :example, 'mysite.org'
                  key :description, "The domain or URL for the user's personal website"
                end
                property :total_scopus_citations do
                  key :type, :integer
                  key :example, 76
                  key :description, "The total number of times that all of the user's publications have been cited as recorded in Scopus (Pure)"
                end
                property :scopus_h_index do
                  key :type, :integer
                  key :example, 24
                  key :description, "The user's H-Index value in Scopus (Pure)"
                end
                property :pure_profile_url do
                  key :type, :string
                  key :example, 'https://pennstate.pure.elsevier.com/en/persons/abc123-def456'
                  key :description, "The URL for the user's profile page on the Penn State Pure website"
                end
                property :orcid_identifier do
                  key :type, :string
                  key :example, 'https://orcid.org/0000-0000-0000-0000'
                  key :description, "The URL for the user's ORCID ID"
                end
                property :bio do
                  key :type, :string
                  key :example, 'Some biographical information about this user'
                  key :description, 'A brief biography of the user'
                end
                property :teaching_interests do
                  key :type, :string
                  key :example, 'Computer Science, Information Technology'
                  key :description, "A description of the user's teaching interests"
                end
                property :research_interests do
                  key :type, :string
                  key :example, 'Quantum Computing, Encryption'
                  key :description, "A description of the user's research interests"
                end
                property :publications do
                  key :type, :array
                  items do
                    key :type, :string
                    key :example, '<span class="publication-title">My Publication</span>, <span class="journal-name">Journal of Medicine</span>, 2010'
                    key :description, 'A string of HTML describing a journal article'
                  end
                end
                property :grants do
                  key :type, :array
                  items do
                    key :type, :string
                    key :example, 'My Grant, NSF, 5/2007 - 5/2009'
                    key :description, 'A description of an awarded grant'
                  end
                end
                property :presentations do
                  key :type, :array
                  items do
                    key :type, :string
                    key :example, 'My Presentation, Penn State University, University Park'
                    key :description, 'A description of a presentation'
                  end
                end
                property :performances do
                  key :type, :array
                  items do
                    key :type, :string
                    key :example, 'My Performance, Eisenhower Auditorium - Penn State University, 3/1/2016'
                    key :description, 'A description of a performance'
                  end
                end
                property :master_advising_roles do
                  key :type, :array
                  items do
                    key :type, :string
                    key :example, '<a href="https://etda.libraries.psu.edu/catalog/12345" target="_blank">Graduate Student Master Thesis Example</a> (Committee Member)'
                    key :description, 'A description of a graduate student master thesis advising role with an HTML link to the thesis'
                  end
                end
                property :phd_advising_roles do
                  key :type, :array
                  items do
                    key :type, :string
                    key :example, '<a href="https://etda.libraries.psu.edu/catalog/12345" target="_blank">Graduate Student PhD Dissertation Example</a> (Committee Member)'
                    key :description, 'A description of a graduate student PhD dissertation advising role with an HTML link to the dissertation'
                  end
                end
                property :news_stories do
                  key :type, :array
                  items do
                    key :type, :string
                    key :example, '<a href="https://news.psu.edu/my_story" target="_blank">My News Story</a> 9/17/2014'
                    key :description, 'A description of a news story with an HTML link to the story content'
                  end
                end
                property :education_history do
                  key :type, :array
                  items do
                    key :type, :string
                    key :example, 'BS, Biology - The Pennsylvania State University - 2010'
                    key :description, 'A description of a degree earned by the user'
                  end
                end
              end
            end
          end
        end

        response 404 do
          key :description, 'not found'
          schema do
            key :'$ref', :ErrorModelV1
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
