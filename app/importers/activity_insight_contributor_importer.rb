class ActivityInsightContributorImporter < ActivityInsightCSVImporter
  def row_to_object(row)
    p = PublicationImport.find_by(source: ActivityInsightCSVImporter::IMPORT_SOURCE,
                                  source_identifier: row[:parent_id]).try(:publication)

    if p && !p.updated_by_user_at.present? # Depends on publications being imported from Activity Insight first
      p.contributors.delete_all

      c = Contributor.new

      c.publication = p
      c.first_name = row[:fname]
      c.middle_name = row[:mname]
      c.last_name = row[:lname]
      c.position = row[:ordinal].to_i
      c
    else
      nil
    end
  end

  def bulk_import(objects)
    Contributor.import(objects)
  end

  private

  def encoding
    'bom|utf-8'
  end
end