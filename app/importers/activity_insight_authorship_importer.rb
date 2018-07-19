class ActivityInsightAuthorshipImporter < ActivityInsightCSVImporter
  def row_to_object(row)
    if row[:faculty_name].present?
      if ! Authorship.find_by(activity_insight_identifier: row[:id])
        authorship = Authorship.new
        authorship.user = User.find_by(activity_insight_identifier: row[:faculty_name])
        authorship.publication = PublicationImport.find_by(import_source: "Activity Insight",
                                                           source_identifier: row[:parent_id]).publication
        authorship.author_number = row[:ordinal].to_i
        authorship.activity_insight_identifier = row[:id]
        authorship
      else
        nil
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
