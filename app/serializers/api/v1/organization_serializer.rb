# frozen_string_literal: true

module API::V1
  class OrganizationSerializer
    include JSONAPI::Serializer

    attributes :name
  end
end
