require 'swagger_helper'

RSpec.describe 'api/v1/users', type: :request do

  path '/v1/users/{webaccess_id}/organization_memberships' do
    parameter name: :webaccess_id, in: :path, type: :string, description: 'Webaccess ID of user to retrieve organization memberships', required: true

    get 'Retrieve the user\'s organization memberships' do
      tags 'user'
      description 'Returns organization memberships for a user'
      operationId 'findUserOrganizationMemberships'
      produces 'application/json'
  
      response '200', description: 'user organization memberships response' do
        schema type: :object,
               properties: {
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
                         example: 'organization_membership',
                         description: 'The type of the object'
                       },
                       attributes: {
                         type: :object,
                         properties: {
                           organization_name: {
                             type: :string,
                             example: 'Biology',
                             description: 'The name of the organization to which the user belongs'
                           },
                           organization_type: {
                             type: [:string, :null],
                             example: 'Department',
                             description: 'The type of the organization'
                           },
                           position_title: {
                             type: [:string, :null],
                             example: 'Associate Professor of Biology',
                             description: "The user's role or title within the organization"
                           },
                           position_started_on: {
                             type: [:string, :null],
                             example: '2010-09-01',
                             description: 'The date on which the user joined the organization in this role'
                           },
                           position_ended_on: {
                             type: [:string, :null],
                             example: '2012-05-30',
                             description: 'The date on which the user left the organization in this role'
                           }
                         },
                         required: [:organization_name]
                       }
                     }
                   }
                 }
               }
        run_test!
      end
  
      response '401', description: 'unauthorized' do
        schema('$ref' => '#/components/schemas/ErrorModelV1')
        run_test!
      end
  
      response '404', description: 'not found' do
        schema('$ref' => '#/components/schemas/ErrorModelV1')
        run_test!
      end
  
      security [api_key: []]
    end
  end

  path '/v1/users/{webaccess_id}/news_feed_items' do
    get 'Retrieve a user\'s news feed items' do
      operationId 'findUserNewsFeedItems'
      produces ['application/json', 'text/html']
      tags 'user'
      parameter name: :webaccess_id, in: :path, description: 'Webaccess ID of user to retrieve news feed items', required: true, type: :string
  
      response '200', 'user news_feed_items response' do
        schema type: :object, properties: {
          data: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :string, example: '123', description: 'The ID of the object' },
                type: { type: :string, example: 'news_feed_item', description: 'The type of the object' },
                attributes: {
                  type: :object,
                  properties: {
                    title: { type: :string, example: 'News Story', description: 'The title of the news feed item' },
                    url: { type: :string, example: 'https://news.psu.edu/example', description: 'The URL where the full news story content can be found' },
                    description: { type: :string, example: 'A news story about a Penn State researcher', description: 'A brief description of the news story content' },
                    published_on: { type: :string, example: '2018-12-05', description: 'The date on which the news story was published' }
                  },
                  required: [:title, :url, :description, :published_on]
                }
              },
              required: [:id, :type, :attributes]
            }
          }
        },
        required: [:data]
        run_test!
      end
  
      response '401', 'unauthorized' do
        schema('$ref' => '#/components/schemas/ErrorModelV1')
        run_test!
      end
  
      response '404', 'not found' do
        schema('$ref' => '#/components/schemas/ErrorModelV1')
        run_test!
      end
  
      security [{ api_key: [] }]
    end
  end

  path '/v1/users/{webaccess_id}/presentations' do
    get 'Retrieve a user\'s presentations' do
      operationId 'findUserPresentations'
      produces ['application/json', 'text/html']
      tags 'user'

      parameter name: :webaccess_id, in: :path, description: 'Webaccess ID of user to retrieve presentations', required: true, type: :string

      response '200', 'user presentations response' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     required: [:id, :type, :attributes],
                     properties: {
                       id: { type: :string, example: '123', description: 'The ID of the object' },
                       type: { type: :string, example: 'presentation', description: 'The type of the object' },
                       attributes: {
                         type: :object,
                         required: [:activity_insight_identifier],
                         properties: {
                           title: { type: [:string, :null], example: 'A Public Presentation', description: 'The title of the presentation' },
                           activity_insight_identifier: { type: :string, example: '1234567890', description: "The unique identifier for the presentation's corresponding record in the Activity Insight database" },
                           name: { type: [:string, :null], example: 'A Public Presentation', description: 'The name of the presentation' },
                           organization: { type: [:string, :null], example: 'The Pennsylvania State University', description: 'The name of the organization associated with the presentation' },
                           location: { type: [:string, :null], example: 'University Park, PA', description: 'The name of the location where the presentation took place' },
                           started_on: { type: [:string, :null], example: '2018-12-04', description: 'The date on which the presentation started' },
                           ended_on: { type: [:string, :null], example: '2018-12-05', description: 'The date on which the presentation ended' },
                           presentation_type: { type: [:string, :null], example: 'Presentations', description: 'The type of the presentation' },
                           classification: { type: [:string, :null], example: 'Basic or Discovery Scholarship', description: 'The classification of the presentation' },
                           meet_type: { type: [:string, :null], example: 'Academic', description: 'The meet type of the presentation' },
                           attendance: { type: [:integer, :null], example: 200, description: 'The number of people who attended the presentation' },
                           refereed: { type: [:string, :null], example: 'Yes', description: 'Whether or not the presentation was refereed' },
                           abstract: { type: [:string, :null], example: 'A presentation about Penn State academic research', description: 'A summary of the presentation content' },
                           comment: { type: [:string, :null], example: 'The goal of this presentation was to broaden public awareness of a research topic.', description: 'Miscellaneous comments and notes about the presentation' },
                           scope: { type: [:string, :null], example: 'International', description: 'The scope of the audience for the presentation' },
                           profile_preferences: {
                             type: :array,
                             description: 'An array of settings for each user who is an author of the publication indicating how they prefer to have the publication displayed in a profile',
                             items: {
                               type: :object,
                               required: [:user_id, :webaccess_id, :visible_in_profile, :position_in_profile],
                               properties: {
                                 user_id: { type: :number, example: 123, description: 'The ID of the user to which this set of preferences belongs' },
                                 webaccess_id: { type: :string, example: 'abc123', description: 'The WebAccess ID of the user to which this set of preferences belongs' },
                                 visible_in_profile: { type: :boolean, example: true, description: "The user's preference for whether or not this publication should be displayed in their profile" },
                                 position_in_profile: { type: [:number, :null], example: 8, description: "The user's preference for what position this publication should occupy in a list of their publications in their profile" }
                               }
                             }
                           }
                         }
                       }
                     }
                   }
                 }
               }
        run_test!
      end

      response '401', 'unauthorized' do
        schema('$ref' => '#/components/schemas/ErrorModelV1')
        run_test!
      end

      response '404', 'not found' do
        schema('$ref' => '#/components/schemas/ErrorModelV1')
        run_test!
      end

      security [api_key: []]
    end
  end

  path '/v1/users/{webaccess_id}/publications' do
    # You'll want to customize the parameter types...
    parameter name: 'webaccess_id', in: :path, type: :string, description: 'webaccess_id'

    get('publications user') do
      response(200, 'successful') do
        let(:webaccess_id) { '123' }

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

  path '/v1/users/{webaccess_id}/grants' do
    # You'll want to customize the parameter types...
    parameter name: 'webaccess_id', in: :path, type: :string, description: 'webaccess_id'

    get('grants user') do
      response(200, 'successful') do
        let(:webaccess_id) { '123' }

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

  path '/v1/users/{webaccess_id}/performances' do
    # You'll want to customize the parameter types...
    parameter name: 'webaccess_id', in: :path, type: :string, description: 'webaccess_id'

    get('performances user') do
      response(200, 'successful') do
        let(:webaccess_id) { '123' }

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

  path '/v1/users/publications' do

    post('users_publications user') do
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

  path '/v1/users/{webaccess_id}/etds' do
    # You'll want to customize the parameter types...
    parameter name: 'webaccess_id', in: :path, type: :string, description: 'webaccess_id'

    get('etds user') do
      response(200, 'successful') do
        let(:webaccess_id) { '123' }

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

  path '/v1/users/{webaccess_id}/profile' do
    # You'll want to customize the parameter types...
    parameter name: 'webaccess_id', in: :path, type: :string, description: 'webaccess_id'

    get('profile user') do
      response(200, 'successful') do
        let(:webaccess_id) { '123' }

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
