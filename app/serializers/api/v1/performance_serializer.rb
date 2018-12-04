module API::V1
  class PerformanceSerializer
    include FastJsonapi::ObjectSerializer
    attributes :title, :activity_insight_id, :performance_type, :sponsor, :description,
               :group_name, :location, :delivery_type, :scope, :start_on, :end_on

    attribute :user_performances do |object|
      object.user_performances.map do |c|
        {first_name: c.user.first_name,
         last_name: c.user.last_name,
         contribution: c.contribution,
         student_level: c.student_level,
         role_other: c.role_other}
      end
    end

    attribute :performance_screenings do |object|
      object.performance_screenings.map do |c|
        {name: c.name,
         location: c.location,
         screening_type: c.screening_type}
      end
    end
  end
end
