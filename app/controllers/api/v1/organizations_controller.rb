module API::V1
  class OrganizationsController < APIController
    include Swagger::Blocks

    def index
      render json: API::V1::OrganizationSerializer.new(Organization.visible)
    end
  end
end
