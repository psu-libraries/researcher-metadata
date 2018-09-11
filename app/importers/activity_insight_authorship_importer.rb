class ActivityInsightAuthorshipImporter < ActivityInsightCSVImporter
  def row_to_object(row)
    if row[:faculty_name].present?
      u = User.find_by(activity_insight_identifier: row[:faculty_name])
      p = PublicationImport.find_by(source: ActivityInsightCSVImporter::IMPORT_SOURCE,
                                    source_identifier: row[:parent_id]).try(:publication)
      a = Authorship.find_by(user: u, publication: p)

      if p && u && !p.updated_by_user_at.present? # Depends on users and publications being imported from Activity Insight first
        if a
          a.update_attributes!(author_number: row[:ordinal].to_i)
          return nil
        else
          return Authorship.new(user: u,
                                publication: p,
                                author_number: row[:ordinal].to_i)
        end
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
