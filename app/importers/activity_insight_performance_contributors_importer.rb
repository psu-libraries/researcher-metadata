class ActivityInsightPerformanceContributorsImporter < ActivityInsightCSVImporter
  
  def row_to_object(row)
    u = User.find_by(activity_insight_identifier: row[:user_id])

    p = Performance.find_by(activity_insight_id: row[:parent_id])

    return UserPerformance.new(user: u, performance: p)
  end

  private

  def bulk_import(objects)
    UserPerformance.import(objects)
  end

end
