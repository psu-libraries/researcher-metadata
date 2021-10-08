# frozen_string_literal: true

module API::V1
  class PerformanceSerializer
    include FastJsonapi::ObjectSerializer
    attributes :title, :activity_insight_id, :performance_type, :sponsor, :description,
               :group_name, :location, :delivery_type, :scope, :start_on, :end_on

    attribute :user_performances do |object|
      object.user_performances.map do |up|
        { first_name: up.user_first_name,
          last_name: up.user_last_name,
          contribution: up.contribution,
          student_level: up.student_level,
          role_other: up.role_other }
      end
    end

    attribute :performance_screenings do |object|
      object.performance_screenings.map do |ps|
        { name: ps.name,
          location: ps.location,
          screening_type: ps.screening_type }
      end
    end

    attribute :profile_preferences do |object|
      object.user_performances.map do |up|
        { user_id: up.user_id,
          webaccess_id: up.user_webaccess_id,
          visible_in_profile: up.visible_in_profile,
          position_in_profile: up.position_in_profile }
      end
    end
  end
end
