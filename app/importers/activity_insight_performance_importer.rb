class ActivityInsightPerformanceImporter < ActivityInsightCSVImporter

  def row_to_object(row)
    u = User.find_by(webaccess_id: row[:username].downcase)

    p = Performance.find_by(activity_insight_id: row[:id]) ||
        Performance.new(performance_attrs(row))
    if p.persisted?
      p.update_attributes!(performance_attrs(row))
      return nil
    else
      p.save!
      return UserPerformance.new(user: u, performance: p)
    end
  end

  private

  def bulk_import(objects)
    UserPerformance.import(objects)
  end

  def performance_attrs(row)
    {
      title: row[:title],
      performance_type: performance_type(row),
      type_other: row[:type_other],
      sponsor: sponsor(row),
      description: description(row),
      group_name: row[:name],
      location: row[:location],
      delivery_type: row[:delivery_type],
      scope: row[:scope],
      start_on: row[:start_start],
      end_on: row[:end_start],
      activity_insight_id: row[:id]
    }
  end

  def performance_type(row)
    extract_value(row: row, header_key: :type, header_count: 4) || row[:type_other]
  end

  def description(row)
    extract_value(row: row, header_key: :desc, header_count: 2)
  end

  def sponsor(row)
    extract_value(row: row, header_key: :sponsor, header_count: 2)
  end

  def extract_value(row:, header_key:, header_count:)
    value = nil
    header_count.times do |i|
      if i == 0
        value = row[header_key] if row[header_key].present? && row[header_key].to_s.downcase != 'other'
      else
        key = header_key.to_s + (i+1).to_s
        value = row[key.to_sym] if row[key.to_sym].present? && row[key.to_sym].to_s.downcase != 'other'
      end
    end
    value
  end
end

