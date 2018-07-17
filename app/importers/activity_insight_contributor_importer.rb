class ActivityInsightContributorImporter < ActivityInsightCSVImporter
  def row_to_object(row)
    pi = PublicationImport.find_by(import_source: 'Activity Insight', source_identifier: row[:parent_id])

    if pi
      unless ContributorImport.find_by(import_source: 'Activity Insight', source_identifier: row[:id])
        ci = ContributorImport.new
        ci.publication_import = pi
        ci.first_name = row[:fname]
        ci.middle_name = row[:mname]
        ci.last_name = row[:lname]
        ci.import_source = 'Activity Insight'
        ci.source_identifier = row[:id]
        ci.position = row[:ordinal].to_i

        c = Contributor.new
        c.publication = pi.publication
        c.first_name = row[:fname]
        c.middle_name = row[:mname]
        c.last_name = row[:lname]
        c.position = row[:ordinal].to_i
        c.save!

        ci
      end
    else
      nil
    end
  end

  def bulk_import(objects)
    ContributorImport.import(objects)
  end

  private

  def encoding
    'bom|utf-8'
  end
end