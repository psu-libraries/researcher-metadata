class ActivityInsightPerformanceScreeningImporter < ActivityInsightCSVImporter

  def row_to_object(row)
    p = Performance.find_by(activity_insight_id: row[:parent_id])

    ps = PerformanceScreening.find_by(activity_insight_id: row[:id]) ||
      PerformanceScreening.new(performance_screening_attrs(row).merge!(performance: p))

    if ps.persisted?
      ps.update_attributes!(performance_screening_attrs(row))
      return nil
    else
      return ps
    end
  end

  private

  def bulk_import(objects)
    PerformanceScreening.import(objects)
  end

  def performance_screening_attrs(row)
    {
      screening_type: row[:type],
      name: row[:name],
      location: row[:location],
      activity_insight_id: row[:id]
    }
  end

  def encoding
    'bom|utf-8'
  end

end
