# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/users' do
  path '/v1/users/{webaccess_id}/organization_memberships' do
    parameter name: :webaccess_id, in: :path, type: :string, description: 'Webaccess ID of user to retrieve organization memberships', required: true

    get 'Retrieve the user\'s organization memberships' do
      tags 'user'
      description 'Returns organization memberships for a user'
      operationId 'findUserOrganizationMemberships'
      produces 'application/json'

      response 200, 'user organization memberships response' do
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

      response 401, 'unauthorized' do
        schema '$ref' => '#/components/schemas/ErrorModelV1'
        run_test!
      end

      response 404, 'not found' do
        schema '$ref' => '#/components/schemas/ErrorModelV1'
        run_test!
      end

      security [api_key: []]
    end
  end

  path '/v1/users/{webaccess_id}/news_feed_items' do
    get 'Retrieve a user\'s news feed items' do
      operationId 'findUserNewsFeedItems'
      produces 'application/json', 'text/html'
      tags 'user'
      description 'Returns a news feed items for a user'
      parameter name: :webaccess_id, in: :path, description: 'Webaccess ID of user to retrieve news feed items', required: true, type: :string

      response 200, 'user news_feed_items response' do
        schema type: :object, properties: {
                                data: {
                                  type: :array,
                                  items: {
                                    type: :object,
                                    properties: {
                                      id: { type: :string,
                                            example: '123',
                                            description: 'The ID of the object' },
                                      type: { type: :string,
                                              example: 'news_feed_item',
                                              description: 'The type of the object' },
                                      attributes: {
                                        type: :object,
                                        properties: {
                                          title: { type: :string,
                                                   example: 'News Story',
                                                   description: 'The title of the news feed item' },
                                          url: { type: :string,
                                                 example: 'https://news.psu.edu/example',
                                                 description: 'The URL where the full news story content can be found' },
                                          description: { type: :string,
                                                         example: 'A news story about a Penn State researcher',
                                                         description: 'A brief description of the news story content' },
                                          published_on: { type: :string,
                                                          example: '2018-12-05',
                                                          description: 'The date on which the news story was published' }
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

      response 401, 'unauthorized' do
        schema '$ref' => '#/components/schemas/ErrorModelV1'
        run_test!
      end

      response 404, 'not found' do
        schema '$ref' => '#/components/schemas/ErrorModelV1'
        run_test!
      end

      security [{ api_key: [] }]
    end
  end

  path '/v1/users/{webaccess_id}/presentations' do
    get 'Retrieve a user\'s presentations' do
      operationId 'findUserPresentations'
      produces 'application/json', 'text/html'
      tags 'user'
      description 'Returns presentations for a user'

      parameter name: :webaccess_id,
                in: :path,
                description: 'Webaccess ID of user to retrieve presentations',
                required: true,
                type: :string

      response 200, 'user presentations response' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     required: [:id, :type, :attributes],
                     properties: {
                       id: { type: :string,
                             example: '123',
                             description: 'The ID of the object' },
                       type: { type: :string,
                               example: 'presentation',
                               description: 'The type of the object' },
                       attributes: {
                         type: :object,
                         required: [:activity_insight_identifier],
                         properties: {
                           title: { type: [:string, :null],
                                    example: 'A Public Presentation',
                                    description: 'The title of the presentation' },
                           activity_insight_identifier: { type: :string,
                                                          example: '1234567890',
                                                          description: "The unique identifier for the presentation's corresponding record in the Activity Insight database" },
                           name: { type: [:string, :null],
                                   example: 'A Public Presentation',
                                   description: 'The name of the presentation' },
                           organization: { type: [:string, :null],
                                           example: 'The Pennsylvania State University',
                                           description: 'The name of the organization associated with the presentation' },
                           location: { type: [:string, :null],
                                       example: 'University Park, PA',
                                       description: 'The name of the location where the presentation took place' },
                           started_on: { type: [:string, :null],
                                         example: '2018-12-04',
                                         description: 'The date on which the presentation started' },
                           ended_on: { type: [:string, :null],
                                       example: '2018-12-05',
                                       description: 'The date on which the presentation ended' },
                           presentation_type: { type: [:string, :null],
                                                example: 'Presentations',
                                                description: 'The type of the presentation' },
                           classification: { type: [:string, :null],
                                             example: 'Basic or Discovery Scholarship',
                                             description: 'The classification of the presentation' },
                           meet_type: { type: [:string, :null],
                                        example: 'Academic',
                                        description: 'The meet type of the presentation' },
                           attendance: { type: [:integer, :null],
                                         example: 200,
                                         description: 'The number of people who attended the presentation' },
                           refereed: { type: [:string, :null],
                                       example: 'Yes',
                                       description: 'Whether or not the presentation was refereed' },
                           abstract: { type: [:string, :null],
                                       example: 'A presentation about Penn State academic research',
                                       description: 'A summary of the presentation content' },
                           comment: { type: [:string, :null],
                                      example: 'The goal of this presentation was to broaden public awareness of a research topic.',
                                      description: 'Miscellaneous comments and notes about the presentation' },
                           scope: { type: [:string, :null],
                                    example: 'International',
                                    description: 'The scope of the audience for the presentation' },
                           profile_preferences: {
                             type: :array,
                             description: 'An array of settings for each user who is an author of the publication indicating how they prefer to have the publication displayed in a profile',
                             items: {
                               type: :object,
                               required: [:user_id, :webaccess_id, :visible_in_profile, :position_in_profile],
                               properties: {
                                 user_id: { type: :number,
                                            example: 123,
                                            description: 'The ID of the user to which this set of preferences belongs' },
                                 webaccess_id: { type: :string,
                                                 example: 'abc123',
                                                 description: 'The WebAccess ID of the user to which this set of preferences belongs' },
                                 visible_in_profile: { type: :boolean,
                                                       example: true,
                                                       description: "The user's preference for whether or not this publication should be displayed in their profile" },
                                 position_in_profile: { type: [:number, :null],
                                                        example: 8,
                                                        description: "The user's preference for what position this publication should occupy in a list of their publications in their profile" }
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

      response 401, 'unauthorized' do
        schema '$ref' => '#/components/schemas/ErrorModelV1'
        run_test!
      end

      response 404, 'not found' do
        schema '$ref' => '#/components/schemas/ErrorModelV1'
        run_test!
      end

      security [api_key: []]
    end
  end

  path '/v1/users/{webaccess_id}/grants' do
    get 'Retrieve a user\'s grants' do
      tags 'user'
      produces 'application/json', 'text/html'
      operationId 'findUserGrants'
      description 'Returns grant data for a user'
      parameter name: :webaccess_id,
                in: :path,
                description: 'Webaccess ID of user to retrieve grants',
                required: true,
                type: :string

      response 200, 'user grants response' do
        schema type: :object, properties: {
          data: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :string,
                      example: '123',
                      description: 'The ID of the object' },
                type: { type: :string,
                        example: 'grant',
                        description: 'The type of the object' },
                attributes: {
                  type: :object,
                  properties: {
                    title: { type: [:string, :null],
                             example: 'A Research Project Proposal',
                             description: 'The title of the grant' },
                    agency: { type: [:string, :null],
                              example: 'National Science Foundation',
                              description: 'The name of the organization that awarded the grant' },
                    abstract: { type: [:string, :null],
                                example: 'Information about this grant',
                                description: "A description of the grant's purpose" },
                    amount_in_dollars: { type: [:integer, :null],
                                         example: 50000,
                                         description: 'The monetary amount of the grant in U.S. dollars' },
                    start_date: { type: [:string, :null],
                                  example: '2017-12-05',
                                  description: 'The date on which the grant begins' },
                    end_date: { type: [:string, :null],
                                example: '2019-12-05',
                                description: 'The date on which the grant ends' },
                    identifier: { type: [:string, :null],
                                  example: '1789352',
                                  description: 'A code identifying the grant that is unique to the awarding agency' }
                  },
                  required: [:title, :agency, :abstract, :amount_in_dollars,
                             :start_date, :end_date, :identifier]
                }
              },
              required: [:id, :type, :attributes]
            }
          }
        }

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

      security [api_key: []]
    end
  end

  path '/v1/users/{webaccess_id}/performances' do
    get 'Retrieve a user\'s performances' do
      tags 'user'
      produces 'application/json', 'text/html'
      operationId 'findPerformances'
      description 'Returns performances for a user'
      parameter name: :webaccess_id,
                in: :path,
                description: 'Webaccess ID of user to retrieve performances',
                required: true,
                type: :string

      response 200, 'user performances response' do
        schema type: :object, properties: {
          data: {
            type: :array,
            items: {
              type: :object,
              required: [:id, :type, :attributes],
              properties: {
                id: { type: :string,
                      example: '123',
                      description: 'The ID of the object' },
                type: { type: :string,
                        example: 'performance',
                        description: 'The type of the object' },
                attributes: {
                  type: :object,
                  required: [:title, :activity_insight_id],
                  properties: {
                    title: { type: :string,
                             example: 'Example Performance',
                             description: 'The title of the performance' },
                    activity_insight_id: { type: :integer,
                                           example: '1234567890',
                                           description: "The unique identifier for the performance's corresponding record in the Activity Insight database" },
                    performance_type: { type: [:string, :null],
                                        example: 'Film - Documentary',
                                        description: 'The type of performance' },
                    sponsor: { type: [:string, :null],
                               example: 'Penn State',
                               description: 'The organization that is sponsoring this performance' },
                    description: { type: [:string, :null],
                                   example: 'This is a unique performance, performed for specific reasons',
                                   description: 'Any further detail describing the performance' },
                    group_name: { type: [:string, :null],
                                  example: 'Penn State Performers',
                                  description: 'The name of the performing group' },
                    location: { type: [:string, :null],
                                example: 'State College, PA',
                                description: 'Country, State, City, theatre, etc. where the performance took place' },
                    delivery_type: { type: [:string, :null],
                                     example: 'Competition',
                                     description: 'Audition, commission, competition, or invitation' },
                    scope: { type: [:string, :null],
                             example: 'Local',
                             description: 'International, national, regional, state, local' },
                    start_on: { type: [:string, :null],
                                example: '12-01-2015',
                                description: 'The date that the performance started on' },
                    end_on: { type: [:string, :null],
                              example: '12-31-2015',
                              description: 'The date that the performance ended on' },
                    user_performances: {
                      type: :array,
                      items: {
                        type: :object,
                        properties: {
                          first_name: { type: [:string, :null],
                                        example: 'Billy',
                                        description: 'The first name of a contributor' },
                          last_name: { type: [:string, :null],
                                       example: 'Bob',
                                       description: 'The last name of a contributor' },
                          contribution: { type: [:string, :null],
                                          example: 'Performer',
                                          description: 'The contributor\'s role/contribution to the performance' },
                          student_level: { type: [:string, :null],
                                           example: 'Graduate',
                                           description: 'Undergraduate or graduate' },
                          role_other: { type: [:string, :null],
                                        example: 'Director',
                                        description: 'Role not listedin "contribution" drop-down' }
                        }
                      }
                    },
                    performance_screenings: {
                      type: :array,
                      items: {
                        type: :object,
                        properties: {
                          name: { type: [:string, :null],
                                  example: 'Film Festival',
                                  description: 'Name of the venue for the screening' },
                          location: { type: [:string, :null],
                                      example: 'State College, PA',
                                      description: 'Country, State, City, where the screening took place' },
                          screening_type: { type: [:string, :null],
                                            example: 'DVD Distribution',
                                            description: 'Type of screening/exhibition' }
                        }
                      }
                    },
                    profile_preferences: {
                      type: :array,
                      description: 'An array of settings for each user who is an author of the publication indicating how they prefer to have the publication displayed in a profile',
                      items: {
                        type: :object,
                        required: [:user_id, :webaccess_id, :visible_in_profile, :position_in_profile],
                        properties: {
                          user_id: { type: :number,
                                     example: 123,
                                     description: 'The ID of the user to which this set of preferences belongs' },
                          webaccess_id: { type: :string,
                                          example: 'abc123',
                                          description: 'The WebAccess ID of the user to which this set of preferences belongs' },
                          visible_in_profile: { type: :boolean,
                                                example: true,
                                                description: 'The user\'s preference for whether or not this publication should be displayed in their profile' },
                          position_in_profile: { type: [:number, :null],
                                                 example: 8,
                                                 description: 'The user\'s preference for what position this publication should occupy in a list of their publications in their profile' }
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

      response 401, 'unauthorized' do
        schema '$ref' => '#/components/schemas/ErrorModelV1'
        run_test!
      end

      response 404, 'not found' do
        schema '$ref' => '#/components/schemas/ErrorModelV1'
        run_test!
      end

      security [api_key: []]
    end
  end

  path '/v1/users/{webaccess_id}/etds' do
    get 'Retrieve a user\'s student advising history' do
      tags 'user'
      produces 'application/json', 'text/html'
      description 'Returns ETDs for which the user served on the committee'
      operationId 'findUserETDs'
      parameter name: :webaccess_id,
                in: :path,
                description: 'Webaccess ID of user to retrieve ETDs',
                required: true,
                type: :string

      response 200, 'user ETDs response' do
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
                type: { type: :string,
                        example: 'etd',
                        description: 'The type of the object' },
                attributes: {
                  type: :object,
                  required: [:title, :year, :author_last_name, :author_first_name],
                  properties: {
                    title: {
                      type: :string,
                      example: 'A PhD Thesis',
                      description: 'The title of the ETD'
                    },
                    year: {
                      type: :integer,
                      example: 2010,
                      description: 'The year in which the ETD was completed'
                    },
                    author_last_name: {
                      type: :string,
                      example: 'Author',
                      description: "The last name of the ETD's author"
                    },
                    author_first_name: {
                      type: :string,
                      example: 'Susan',
                      description: "The first name of the ETD's author"
                    },
                    author_middle_name: {
                      type: [:string, :null],
                      example: 'Example',
                      description: "The first name of the ETD's author"
                    }
                  }
                }
              }
            }
          }
        }
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

      security [api_key: []]
    end
  end

  path '/v1/users/{webaccess_id}/publications' do
    get 'Retrieve a user\'s publications' do
      tags 'user'
      produces 'application/json', 'text/html'
      operationId 'findUserPublications'
      description 'Returns a publications for a user'
      parameter name: :webaccess_id,
                in: :path,
                description: 'Webaccess ID of user to retrieve publications',
                required: true, type: :string
      parameter name: :start_year,
                in: :query,
                description: 'Beginning of publication year range',
                required: false,
                type: :integer,
                format: :int32
      parameter name: :end_year,
                in: :query,
                description: 'End of publication year range',
                required: false,
                type: :integer,
                format: :int32
      parameter name: :order_first_by,
                in: :query,
                description: 'Orders publications returned',
                required: false,
                schema: {
                  type: :string,
                  enum: [:citation_count_desc,
                         :publication_date_asc,
                         :publication_date_desc,
                         :title_asc]
                }
      parameter name: :order_second_by,
                in: :query,
                description: 'Orders publications returned',
                required: false,
                schema: {
                  type: :string,
                  enum: [:citation_count_desc,
                         :publication_date_asc,
                         :publication_date_desc, :title_asc]
                }
      parameter name: :limit,
                in: :query,
                description: 'Max number publications to return for the user',
                required: false,
                type: :integer,
                format: :int32

      response 200, 'user publication response' do
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
        schema '$ref' => '#/components/schemas/ErrorModelV1'
        run_test!
      end

      response 404, 'not found' do
        schema '$ref' => '#/components/schemas/ErrorModelV1'
        run_test!
      end

      security [api_key: []]
    end
  end

  path '/v1/users/{webaccess_id}/profile' do
    get 'Retrieve a user\'s profile' do
      tags 'user'
      produces 'application/json', 'text/html'
      description "Returns a representation of a user's profile information"
      parameter name: :webaccess_id,
                in: :path,
                type: :string,
                required: true,
                description: 'Webaccess ID of user to retrieve HTML profile'

      response 200, 'user profile response' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :string,
                           example: '123',
                           description: 'The ID of the user' },
                     type: { type: :string,
                             example: 'user_profile',
                             description: 'The type of the object' },
                     attributes: {
                       type: :object,
                       properties: {
                         name: { type: :string,
                                 example: 'Example User',
                                 description: 'The full name of the user' },
                         organization_name: { type: :string,
                                              example: 'College of Engineering',
                                              description: "The name of the user's primary organization" },
                         title: { type: :string,
                                  example: 'Professor',
                                  description: "The title of the user's position" },
                         email: { type: :string,
                                  example: 'abc123@psu.edu',
                                  description: "The user's email address" },
                         office_location: { type: :string,
                                            example: '101 Chemistry Building',
                                            description: "The room number and building where the user's office is located" },
                         office_phone_number: { type: :string,
                                                example: '(555) 555-555',
                                                description: "The telephone number for the user's office" },
                         personal_website: { type: :string,
                                             example: 'mysite.org',
                                             description: "The domain or URL for the user's personal website" },
                         total_scopus_citations: { type: :integer,
                                                   example: 76,
                                                   description: "The total number of times that all of the user's publications have been cited as recorded in Scopus (Pure)" },
                         scopus_h_index: { type: :integer,
                                           example: 24,
                                           description: "The user's H-Index value in Scopus (Pure)" },
                         pure_profile_url: { type: :string,
                                             example: 'https://pennstate.pure.elsevier.com/en/persons/abc123-def456',
                                             description: "The URL for the user's profile page on the Penn State Pure website" },
                         orcid_identifier: { type: :string,
                                             example: 'https://orcid.org/0000-0000-0000-0000',
                                             description: "The URL for the user's ORCID ID" },
                         bio: { type: :string,
                                example: 'Some biographical information about this user',
                                description: 'A brief biography of the user' },
                         teaching_interests: { type: :string,
                                               example: 'Computer Science, Information Technology',
                                               description: "A description of the user's teaching interests" },
                         research_interests: { type: :string,
                                               example: 'Quantum Computing, Encryption',
                                               description: "A description of the user's research interests" },
                         publications: { type: :array,
                                         items: {
                                           type: :string,
                                           example: '<span class="publication-title">My Publication</span>, <span class="journal-name">Journal of Medicine</span>, 2010',
                                           description: 'A string of HTML describing a journal article'
                                         } },
                         other_publications: {
                           type: :object,
                           properties: {
                             Books: {
                               type: :array,
                               items: {
                                 type: :string,
                                 example: '<span class="publication-title">My Book</span>, <span class="journal-name">Journal of Science</span>, 2012'
                               }
                             },
                             Letters: {
                               type: :array,
                               items: {
                                 type: :string,
                                 example: '<span class="publication-title">My Letter</span>, <span class="journal-name">Journal of Physics</span>, 2011'
                               }
                             }
                           },
                           description: 'A JSON object containing arrays of strings of HTML describing non-journal publications'
                         },
                         grants: {
                           type: :array,
                           items: {
                             type: :string,
                             example: 'My Grant, NSF, 5/2007 - 5/2009',
                             description: 'A description of an awarded grant'
                           }
                         },
                         presentations: {
                           type: :array,
                           items: {
                             type: :string,
                             example: 'My Presentation, Penn State University, University Park',
                             description: 'A description of a presentation'
                           }
                         },
                         performances: {
                           type: :array,
                           items: {
                             type: :string,
                             example: 'My Performance, Eisenhower Auditorium - Penn State University, 3/1/2016',
                             description: 'A description of a performance'
                           }
                         },
                         master_advising_roles: {
                           type: :array,
                           items: {
                             type: :string,
                             example: '<a href="https://etda.libraries.psu.edu/catalog/12345" target="_blank">Graduate Student Master Thesis Example</a> (Committee Member)',
                             description: 'A description of a graduate student master thesis advising role with an HTML link to the thesis'
                           }
                         },
                         phd_advising_roles: {
                           type: :array,
                           items: {
                             type: :string,
                             example: '<a href="https://etda.libraries.psu.edu/catalog/12345" target="_blank">Graduate Student PhD Dissertation Example</a> (Committee Member)',
                             description: 'A description of a graduate student PhD dissertation advising role with an HTML link to the dissertation'
                           }
                         },
                         news_stories: {
                           type: :array,
                           items: {
                             type: :string,
                             example: '<a href="https://news.psu.edu/my_story" target="_blank">My News Story</a> 9/17/2014',
                             description: 'A description of a news story with an HTML link to the story content'
                           }
                         },
                         education_history: {
                           type: :array,
                           items: {
                             type: :string,
                             example: 'BS, Biology - The Pennsylvania State University - 2010',
                             description: 'A description of a degree earned by the user'
                           }
                         }
                       },
                       required: [:name, :organization_name, :title,
                                  :email, :office_location, :office_phone_number,
                                  :personal_website, :total_scopus_citations,
                                  :scopus_h_index, :pure_profile_url, :orcid_identifier,
                                  :bio, :teaching_interests, :research_interests,
                                  :publications, :other_publications, :grants,
                                  :presentations, :performances, :master_advising_roles,
                                  :phd_advising_roles, :news_stories, :education_history]
                     }
                   },
                   required: [:id, :type, :attributes]
                 }
               }
        run_test!
      end

      response 404, 'not found' do
        schema '$ref' => '#/components/schemas/ErrorModelV1'
        run_test!
      end
    end
  end

  path '/v1/users/publications' do
    post 'Retrieve publications for a group of users' do
      tags 'user'
      operationId 'findUsersPublications'
      description 'Returns publications for a group of users'
      parameter name: :start_year,
                in: :query,
                description: 'Beginning of publication year range',
                required: false,
                type: :integer,
                format: :int32
      parameter name: :end_year,
                in: :query,
                description: 'End of publication year range',
                required: false,
                type: :integer,
                format: :int32
      parameter name: :order_first_by,
                in: :query,
                description: 'Orders publications returned',
                required: false,
                schema: { type: :string,
                          enum: [:citation_count_desc,
                                 :publication_date_asc,
                                 :publication_date_desc,
                                 :title_asc] }
      parameter name: :order_second_by,
                in: :query,
                description: 'Orders publications returned',
                required: false,
                schema: { type: :string,
                          enum: [:citation_count_desc,
                                 :publication_date_asc,
                                 :publication_date_desc,
                                 :title_asc] }
      parameter name: :limit,
                in: :query,
                description: 'Max number publications to return for each user',
                required: false,
                type: :integer,
                format: :int32
      parameter name: :webaccess_ids,
                in: :body,
                description: 'Webaccess IDs of users to retrieve publications',
                required: true,
                schema: {
                  type: :array,
                  items: {
                    type: :string
                  }
                }

      response 200, 'OK' do
        run_test!
      end

      response 401, 'unauthorized' do
        schema '$ref' => '#/components/schemas/ErrorModelV1'
        run_test!
      end

      security [api_key: []]
    end
  end
end
