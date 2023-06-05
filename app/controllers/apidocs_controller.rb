# frozen_string_literal: true

class ApidocsController < ApplicationController
  #   include Swagger::Blocks

  #   swagger_root do
  #     key :swagger, '2.0'
  #     info do
  #       key :version, '1.0.0'
  #       key :title, 'Researcher Metadata Database API'
  #       key :description, 'An API that serves as the authority on faculty and ' \
  #                         'research metadata at Penn State University ' \
  #                         'in the swagger-2.0 specification.'
  #     end
  #     key :basePath, '/'
  #     key :consumes, ['application/json']
  #     key :produces, ['application/json']
  #     security_definition :api_key do
  #       key :type, :apiKey
  #       key :name, :'X-API-Key'
  #       key :in, :header
  #     end
  #   end

  #   swagger_schema :ErrorModelV1 do
  #     key :required, [:code, :message]
  #     property :code do
  #       key :type, :integer
  #       key :format, :int32
  #     end
  #     property :message do
  #       key :type, :string
  #     end
  #   end

  def index
    render json: Swagger::Blocks.build_root_json(SwaggeredClasses.all)
  end
end
