module API::V1
  class OrganizationSerializer
    include FastJsonapi::ObjectSerializer
    attributes :id, :name
  end
end
