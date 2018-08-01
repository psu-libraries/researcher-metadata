class ActivityInsightContributorImporter < ActivityInsightCSVImporter
  def row_to_object(row)
    p = Publication.find_by(activity_insight_identifier: row[:parent_id])

    if p # Depends on publications being imported from Activity Insight first
      c = Contributor.find_by(activity_insight_identifier: row[:id]) || Contributor.new

      c.publication = p
      c.first_name = row[:fname]
      c.middle_name = row[:mname]
      c.last_name = row[:lname]
      c.position = row[:ordinal].to_i
      c.activity_insight_identifier = row[:id] if c.new_record?
      c
    else
      nil
    end
  end

  def bulk_import(objects)
    Contributor.import(objects, on_duplicate_key_update: {conflict_target: [:activity_insight_identifier],
                                                          columns: [:first_name,
                                                                    :middle_name,
                                                                    :last_name,
                                                                    :position]})
  end

  private

  def encoding
    'bom|utf-8'
  end
end