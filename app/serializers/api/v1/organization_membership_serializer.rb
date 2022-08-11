# frozen_string_literal: true

module API::V1
  class OrganizationMembershipSerializer
    include JSONAPI::Serializer

    attribute :organization_name do |object|
      object.organization.name
    end

    attribute :organization_type do |object|
      object.organization.organization_type
    end

    attributes :position_title

    attribute :position_started_on, &:started_on

    attribute :position_ended_on, &:ended_on
  end
end
