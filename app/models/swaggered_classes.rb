class SwaggeredClasses
  def self.all
    [
      API::V1::PublicationsController,
      API::V1::UsersController,
      ApidocsController,
      Publication,
      User
    ].freeze
  end
end
