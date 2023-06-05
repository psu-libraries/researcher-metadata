# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.to_s + '/public/api-docs'

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Researcher Metadata Database API',
        description: 'An API that serves as the authority on faculty and ' \
                      'research metadata at Penn State University ' \
                      'in the swagger-2.0 specification.',
        version: 'v1'
      },
      basePath: '/',
      consumes: ['application/json'],
      produces: ['application/json'],
      components: {
        securitySchemes: {
          api_key: {
            type: :apiKey,
            name: 'X-API-Key',
            in: :header
          }
        },
        schemas: {
          ErrorModelV1: {
            type: :object,
            required: [:code, :message],
            properties: {
              code: {
                type: :integer,
                format: :int32
              },
              message: {
                type: :string
              }
            }
          },
          PublicationV1: {
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
                example: 'publication',
                description: 'The type of the object'
              },
              attributes: {
                type: :object,
                required: [:title, :publication_type, :contributors, :tags, :pure_ids, :activity_insight_ids],
                properties: { 
                  title: {
                    type: :string,
                    example: 'A Scholarly Research Article',
                    description: 'The title of the publication'
                  },
                  secondary_title: {
                    type: [:string, :null],
                    example: 'A Comparative Analysis',
                    description: 'The sub-title of the publication'
                  },
                  journal_title: {
                    type: [:string, :null],
                    example: 'An Academic Journal',
                    description: 'The title of the journal in which the publication was published'
                  },
                  publication_type: {
                    type: :string,
                    example: 'Academic Journal Article',
                    description: 'The type of the publication'
                  },
                  publisher: {
                    type: [:string, :null],
                    example: 'A Publishing Company',
                    description: 'The publisher of the publication'
                  },
                  status: {
                    type: [:string, :null],
                    example: 'Published',
                    description: 'The status of the publication'
                  },
                  volume: {
                    type: [:string, :null],
                    example: '30',
                    description: 'The volume of the journal in which the publication was published'
                  },
                  issue: {
                    type: [:string, :null],
                    example: '12',
                    description: 'The issue of the journal in which the publication was published'
                  },
                  edition: {
                    type: [:string, :null],
                    example: '6',
                    description: 'The edition of the journal in which the publication was published'
                  },
                  page_range: {
                    type: [:string, :null],
                    example: '110-123',
                    description: 'The range of page numbers on which the publication content appears in the journal'
                  },
                  authors_et_al: {
                    type: [:boolean, :null],
                    example: true,
                    description: 'Whether or not the publication has additional, unlisted authors'
                  },
                  abstract: {
                    type: [:string, :null],
                    example: 'A summary of the research',
                    description: 'A brief summary of the content of the publication'
                  },
                  doi: {
                    type: [:string, :null],
                    example: 'https://doi.org/example',
                    description: 'The Digital Object Identifier URL for the publication'
                  },
                  preferred_open_access_url: {
                    type: [:string, :null],
                    example: 'https://example.org/articles/article-123.pdf',
                    description: 'A URL for an open access copy of the publication'
                  },
                  published_on: {
                    type: [:string, :null],
                    example: '2010-12-05',
                    description: 'The date on which the publication was published'
                  },
                  citation_count: {
                    type: [:integer, :null],
                    example: 50,
                    description: 'The number of times that the publication has been cited in other works'
                  },
                  contributors: {
                    type: :array,
                    items: {
                      type: :object,
                      properties: {
                        first_name: {
                          type: [:string, :null],
                          example: 'Anne',
                          description: 'The first name of a person who contributed to the publication'
                        },
                        middle_name: {
                          type: [:string, :null],
                          example: 'Example',
                          description: 'The middle name of a person who contributed to the publication'
                        },
                        last_name: {
                          type: [:string, :null],
                          example: 'Contributor',
                          description: 'The last name of a person who contributed to the publication'
                        },
                        psu_user_id: {
                          type: [:string, :null],
                          example: 'abc1234',
                          description: 'The Penn State user ID of a person who contributed to the publication if they have one'
                        }
                      }
                    }
                  },
                  tags: {
                    type: :array,
                    items: {
                      type: :object,
                      required: [:name],
                      properties: {
                        name: {
                          type: :string,
                          example: 'A Topic',
                          description: 'The name of a tag'
                        },
                        rank: {
                          type: [:number, :null],
                          example: 1.25,
                          description: 'The ranking of the tag'
                        }
                      }
                    }
                  },
                  pure_ids: {
                    type: :array,
                    description: 'Unique identifiers for corresponding records in the Pure database that represent the publication',
                    items: {
                      type: :string,
                      example: 'abc-def-123-456'
                    }
                  },
                  activity_insight_ids: {
                    type: :array,
                    description: 'Unique identifiers for corresponding records in the Activity Insight database that represent the publication',
                    items: {
                      type: :string,
                      example: '1234567890'
                    }
                  },
                  profile_preferences: {
                    type: :array,
                    description: 'An array of settings for each user who is an author of the publication indicating how they prefer to have the publication displayed in a profile',
                    items: {
                      type: :object,
                      required: [:user_id, :webaccess_id, :visible_in_profile, :position_in_profile],
                      properties: {
                        user_id: {
                          type: :number,
                          example: 123,
                          description: 'The ID of the user to which this set of preferences belongs'
                        },
                        webaccess_id: {
                          type: :string,
                          example: 'abc123',
                          description: 'The WebAccess ID of the user to which this set of preferences belongs'
                        },
                        visible_in_profile: {
                          type: :boolean,
                          example: true,
                          description: "The user's preference for whether or not this publication should be displayed in their profile"
                        },
                        position_in_profile: {
                          type: [:number, :null],
                          example: 8,
                          description: "The user's preference for what position this publication should occupy in a list of their publications in their profile"
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml
end
