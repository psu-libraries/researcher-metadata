class SwaggeredClasses
  def self.all
    [
      API::V1::PublicationsController,
      ApidocsController,
      Publication
    ].freeze
  end
end
