class ApidocsController < ActionController::Base
  include Swagger::Blocks

  swagger_root do
    key :swagger, '2.0'
    info do
      key :version, '1.0.0'
      key :title, 'PSU Libraries Metadata'
      key :description, 'An API that serves as the authority on faculty and ' \
                        'research data at Penn State University ' \
                        'in the swagger-2.0 specification'
    end
    key :basePath, '/api'
    key :consumes, ['application/json']
    key :produces, ['application/json']
  end

  def index
    render json: Swagger::Blocks.build_root_json(SwaggeredClasses.all)
  end
end
