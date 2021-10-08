# frozen_string_literal: true

class SwaggeredClasses
  def self.all
    [
      API::V1::PublicationsController,
      API::V1::UsersController,
      API::V1::OrganizationsController,
      ApidocsController,
      Publication,
      User
    ].freeze
  end
end
