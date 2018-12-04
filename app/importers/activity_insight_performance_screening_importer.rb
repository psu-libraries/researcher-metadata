class ActivityInsightPerformanceScreeningImporter < ActivityInsightCSVImporter

  def row_to_object(row)
    p = Performance.find_by(activity_insight_id: row[:parent_id])

    return PerformanceScreening.new(performance_screening_attrs(row).merge!(performance: p))
  end

  private

  def bulk_import(objects)
    PerformanceScreening.import(objects)
  end

  def performance_screening_attrs(row)
    {
      screening_type: row[:type],
      name: row[:name],
      location: row[:location]
    }
  end

  def encoding
    'bom|utf-8'
  end

end
