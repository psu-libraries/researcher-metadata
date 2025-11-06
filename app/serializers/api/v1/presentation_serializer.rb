# frozen_string_literal: true

module API::V1
  class PresentationSerializer
    include JSONAPI::Serializer

    attributes :title,
               :activity_insight_identifier,
               :name,
               :organization,
               :location,
               :started_on,
               :ended_on,
               :presentation_type,
               :classification,
               :meet_type,
               :attendance,
               :refereed,
               :abstract,
               :comment,
               :scope

    attribute :profile_preferences do |object|
      object.presentation_contributions.map do |c|
        { user_id: c.user_id,
          webaccess_id: c.user_webaccess_id,
          visible_in_profile: c.visible_in_profile,
          position_in_profile: c.position_in_profile }
      end
    end
  end
end
