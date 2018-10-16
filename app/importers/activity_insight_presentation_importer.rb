class ActivityInsightPresentationImporter < ActivityInsightCSVImporter
  def row_to_object(row)
    existing_presentation = Presentation.find_by(activity_insight_identifier: row[:id])

    if existing_presentation
      if existing_presentation.updated_by_user_at.blank?
        existing_presentation.title = title(row)
        existing_presentation.name = name(row)
        existing_presentation.organization = organization(row)
        existing_presentation.location = location(row)
        existing_presentation.started_on = started_on(row)
        existing_presentation.ended_on = ended_on(row)
        existing_presentation.presentation_type = presentation_type(row)
        existing_presentation.classification = row[:classification]
        existing_presentation.meet_type = row[:meettype]
        existing_presentation.attendance = attendance(row)
        existing_presentation.refereed = row[:refereed]
        existing_presentation.abstract = abstract(row)
        existing_presentation.comment = comment(row)
        existing_presentation.scope = scope(row)
        existing_presentation
      else
        nil
      end
    else
      Presentation.new activity_insight_identifier: row[:id],
                       title: title(row),
                       name: name(row),
                       organization: organization(row),
                       location: location(row),
                       started_on: started_on(row),
                       ended_on: ended_on(row),
                       presentation_type: presentation_type(row),
                       classification: row[:classification],
                       meet_type: row[:meettype],
                       attendance: attendance(row),
                       refereed: row[:refereed],
                       abstract: abstract(row),
                       comment: comment(row),
                       scope: scope(row)
    end
  end

  def bulk_import(objects)
    Presentation.import objects,
                        on_duplicate_key_update: {conflict_target: [:activity_insight_identifier],
                                                  columns: [:title, :name, :organization,
                                                            :location, :started_on, :ended_on,
                                                            :presentation_type, :classification,
                                                            :meet_type, :attendance, :refereed,
                                                            :abstract, :comment, :scope]}
  end

  private

  def title(row)
    extract_value(row: row, header_key: :title, header_count: 2)
  end

  def name(row)
    extract_value(row: row, header_key: :name, header_count: 2)
  end

  def organization(row)
    extract_value(row: row, header_key: :org, header_count: 2)
  end

  def location(row)
    extract_value(row: row, header_key: :location, header_count: 2)
  end

  def started_on(row)
    extracted_date = extract_value(row: row, header_key: :date_start, header_count: 3)
    Date.strptime(extracted_date, '%m/%d/%Y') if extracted_date.present?
  end

  def ended_on(row)
    extracted_date = extract_value(row: row, header_key: :date_end, header_count: 3)
    Date.strptime(extracted_date, '%m/%d/%Y') if extracted_date.present?
  end

  def presentation_type(row)
    extract_value(row: row, header_key: :type, header_count: 9) || row[:type_other]
  end

  def attendance(row)
    extract_value(row: row, header_key: :attendance, header_count: 2)
  end

  def abstract(row)
    extract_value(row: row, header_key: :abstract, header_count: 2)
  end

  def comment(row)
    extract_value(row: row, header_key: :comment, header_count: 2)
  end

  def scope(row)
    extract_value(row: row, header_key: :scope, header_count: 3)
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

  def encoding
    'Windows-1252'
  end
end
