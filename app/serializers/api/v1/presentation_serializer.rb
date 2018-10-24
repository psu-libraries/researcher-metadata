module API::V1
  class PresentationSerializer
    include FastJsonapi::ObjectSerializer
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
  end
end
