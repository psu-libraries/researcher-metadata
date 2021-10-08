# frozen_string_literal: true

module API::V1
  class OrganizationSerializer
    include FastJsonapi::ObjectSerializer
    attributes :name
  end
end
