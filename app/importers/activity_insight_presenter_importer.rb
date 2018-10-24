class ActivityInsightPresenterImporter < ActivityInsightCSVImporter
  def row_to_object(row)
    if row[:faculty_name].present?
      pc = PresentationContribution.find_by(activity_insight_identifier: row[:id]) || PresentationContribution.new

      u = User.find_by(activity_insight_identifier: row[:faculty_name])
      p = Presentation.find_by(activity_insight_identifier: row[:parent_id])

      if u && p
        if pc.new_record?
          pc.activity_insight_identifier = row[:id]
        end

        pc.user = u
        pc.presentation = p
        pc.position = row[:ordinal]
        pc.role = role(row)
        pc
      end
    end
  end

  def bulk_import(objects)
    PresentationContribution.import objects,
                        on_duplicate_key_update: {conflict_target: [:activity_insight_identifier],
                                                  columns: [:user_id,
                                                            :presentation_id,
                                                            :position,
                                                            :role]}
  end

  private

  def role(row)
    extract_value(row: row, header_key: :role, header_count: 4) || row[:role_other]
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
