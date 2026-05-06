# frozen_string_literal: true

module API::V1
  class GrantSerializer
    include JSONAPI::Serializer

    attributes :identifier, :title, :agency_name, :abstract, :amount_in_dollars

    attribute :start_date do |object|
      object.start_date.try(:iso8601)
    end

    attribute :end_date do |object|
      object.end_date.try(:iso8601)
    end
  end
end
