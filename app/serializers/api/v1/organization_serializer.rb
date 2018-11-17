module API::V1
  class OrganizationSerializer
    include FastJsonapi::ObjectSerializer
    attributes :name, :organization_type
  end
end
