class ActivityInsightPerformanceContributorsImporter < ActivityInsightCSVImporter
  
  def row_to_object(row)
    u = User.find_by(activity_insight_identifier: row[:user_id])

    p = Performance.find_by(activity_insight_id: row[:parent_id])

    up =  UserPerformance.where(user: u, performance: p).first ||
      UserPerformance.new(user_performance_attrs(row).merge!(user: u, performance: p))

    if up.persisted?
      up.update_attributes(user_performance_attrs(row))
      return nil
    else
      return up
    end
  end

  private

  def bulk_import(objects)
    UserPerformance.import(objects)
  end

  def user_performance_attrs(row)
    {
      contribution: row[:contribution],
      student_level: row[:student_level],
      role_other: row[:role_other]
    }
  end

  def encoding
    'bom|utf-8'
  end

end
