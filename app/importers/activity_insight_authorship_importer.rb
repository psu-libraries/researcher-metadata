class ActivityInsightAuthorshipImporter < ActivityInsightCSVImporter
  def row_to_object(row)
    if row[:faculty_name].present?
      u = User.find_by(activity_insight_identifier: row[:faculty_name])
      p = Publication.find_by(activity_insight_identifier: row[:parent_id])
      a = Authorship.find_by(user: u, publication: p)

      if a
        a.update_attributes!(author_number: row[:ordinal].to_i,
                             activity_insight_identifier: row[:id])
        nil
      else
        Authorship.new(user: u,
                       publication: p,
                       author_number: row[:ordinal].to_i,
                       activity_insight_identifier: row[:id])
      end
    end
  end

  def bulk_import(objects)
    Authorship.import(objects)
  end

  private

  def encoding
    'bom|utf-8'
  end
end
