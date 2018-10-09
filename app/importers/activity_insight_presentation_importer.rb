class ActivityInsightPresentationImporter < ActivityInsightCSVImporter
  def row_to_object(row)
    existing_presentation = Presentation.find_by(activity_insight_identifier: row[:id])

    if existing_presentation
      if existing_presentation.updated_by_user_at.blank?
        existing_presentation.title = title(row)
        existing_presentation
      else
        nil
      end
    else
      Presentation.new activity_insight_identifier: row[:id],
                       title: title(row)
    end
  end

  def bulk_import(objects)
    Presentation.import objects,
                        on_duplicate_key_update: {conflict_target: [:activity_insight_identifier],
                                                  columns: [:title]}
  end

  private

  def title(row)
    extract_value(row: row, header_key: :title, header_count: 2)
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
