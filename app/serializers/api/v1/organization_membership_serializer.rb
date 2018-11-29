module API::V1
  class OrganizationMembershipSerializer
    include FastJsonapi::ObjectSerializer

    attribute :organization_name do |object|
      object.organization.name
    end

    attribute :organization_type do |object|
      object.organization.organization_type
    end

    attributes :position_title

    attribute :position_started_on do |object|
      object.started_on
    end

    attribute :position_ended_on do |object|
      object.ended_on
    end
  end
end
