class ActivityInsightAuthorshipImporter < ActivityInsightCSVImporter
  def row_to_object(row)
    if row[:faculty_name].present?
      authorship = Authorship.new
      authorship.user = User.find_by(activity_insight_identifier: row[:user_id])
    end
    authorship = Authorship.new

    if row[:faculty_name].present?
      authorship.person = Person.find_by(activity_insight_identifier: row[:user_id])
    else
      authorship.person = Person.create!(first_name: row[:fname], middle_name: row[:mname], last_name: row[:lname])
    end
    authorship.publication = Publication.find_by(activity_insight_identifier: row[:parent_id])
    authorship.author_number = row[:ordinal].to_i
    authorship.activity_insight_identifier = row[:id]
    authorship
  end

  def bulk_import(objects)
    Authorship.import(objects)
  end

  private

  def encoding
    'bom|utf-8'
  end
end
